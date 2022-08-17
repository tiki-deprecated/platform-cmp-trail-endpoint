import 'package:sqlite3/sqlite3.dart';

import '../block/block_model.dart';
import '../block/block_repository.dart';
import '../xchain/xchain_model.dart';
import '../xchain/xchain_repository.dart';
import 'backup_model.dart';

class BackupRepository {
  static const table = 'backup';

  final Database _db;

  BackupRepository(this._db) {
    createTable();
  }

  void createTable() async {
    _db.execute('''
      CREATE TABLE IF NOT EXISTS $table (
        id INTEGER PRIMARY KEY,
        signature TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        block_id INTEGER NOT NULL
      );
    ''');
  }

  void save(BackupModel backup) {
    try {
      _db.execute("INSERT INTO $table VALUES (${backup.toSqlValues()});");
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  List<BackupModel> getAll() {
    return _paged(0);
  }

  BackupModel? getById(int id) {
    List<BackupModel> backups = _select(whereStmt: 'WHERE id = $id');
    return backups.isNotEmpty ? backups[0] : null;
  }

  BackupModel? getByBlockId(int blockId) {
    List<BackupModel> backups = _select(whereStmt: 'WHERE block_id = $blockId');
    return backups.isNotEmpty ? backups[0] : null;
  }

  List<BackupModel> getAfter(DateTime since) {
    int sinceInSeconds = since.millisecondsSinceEpoch ~/ 1000;
    return _select(whereStmt: 'WHERE timestamp >= $sinceInSeconds');
  }

  List<BackupModel> _paged(page, {String? whereStmt}) {
    List<BackupModel> pagedBackups = _select(page: page, whereStmt: whereStmt);
    if (pagedBackups.length == 100) pagedBackups.addAll(_paged(page + 1));
    return pagedBackups;
  }

  // TODO verificar where sem ser raw
  List<BackupModel> _select({int page = 0, String? whereStmt}) {
    int offset = page * 100;
    ResultSet results = _db.select('''
        SELECT 
          $table.id as 'bkp.id',
          $table.signature as 'bkp.signature',
          $table.timestamp as 'bkp.timestamp',
          $table.block_id as 'bkp.block_id',
          ${BlockRepository.table}.id as 'blocks.id',
          ${BlockRepository.table}.version as 'blocks.version',
          ${BlockRepository.table}.previous_hash as 'blocks.previous_hash',
          ${BlockRepository.table}.xchain_id as 'blocks.xchain_id',
          ${BlockRepository.table}.transaction_root as 'blocks.transaction_root',
          ${BlockRepository.table}.transaction_count as 'blocks.transaction_count',
          ${BlockRepository.table}.timestamp as 'blocks.timestamp',
          ${XchainRepository.table}.id as 'xchains.id',
          ${XchainRepository.table}.last_checked as 'xchains.last_checked',
          ${XchainRepository.table}.uri as 'xchains.uri'
        FROM $table as backup
        INNER JOIN ${BlockRepository.table}
          ON backup.block_id = blocks.id
        INNER JOIN ${XchainRepository.table}
          ON blocks.xchain_id = xchain.id 
        ${whereStmt ?? 'WHERE 1=1'}
        LIMIT $offset,100;
        ''');
    List<BackupModel> backups = [];
    for (final Row row in results) {
      Map<String, dynamic> blockMap = {
        'id': row['blocks.id'],
        'version': row['blocks.version'],
        'previous_hash': row['blocks.previous_hash'],
        'transaction_root': row['blocks.transaction_root'],
        'transaction_count': row['blocks.transaction_count'],
        'timestamp': row['blocks.timestamp'],
        'xchain': XchainModel.fromMap({
          'id': row['xchains.id'],
          'last_checked': row['xchains.last_checked'],
          'uri': row['xchains.uri'],
        })
      };
      Map<String, dynamic> bkpMap = {
        'id': row['bkp.id'],
        'signature': row['bkp.signature'],
        'timestamp': row['bkp.timestamp'],
        'block': BlockModel.fromMap(blockMap)
      };
      BackupModel bkp = BackupModel.fromMap(bkpMap);
      backups.add(bkp);
    }
    return backups;
  }
}
