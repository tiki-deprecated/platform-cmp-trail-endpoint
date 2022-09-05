import 'package:sqlite3/sqlite3.dart';

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
        id TEXT PRIMARY KEY,
        signature TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        assef_ref TEXT
      );
    ''');
  }

  void save(BackupModel backup) {
    _db.execute('''INSERT INTO $table VALUES (
        ${backup.id},
        ${backup.signature == null ? null : "'${backup.signature}'"},
        ${backup.timestamp.millisecondsSinceEpoch ~/ 1000},
        '${backup.assetRef}'
      );''');
  }

  //todo remove this.
  List<BackupModel> getAll() {
    return _paged(0);
  }

  BackupModel? getById(int id) {
    List<BackupModel> backups = _select(whereStmt: 'WHERE id = $id');
    return backups.isNotEmpty ? backups[0] : null;
  }

  BackupModel? getByAssetRef(String assetRef) {
    List<BackupModel> backups =
        _select(whereStmt: 'WHERE block_id = "$assetRef"');
    return backups.isNotEmpty ? backups[0] : null;
  }

  List<BackupModel> getAfter(DateTime since) {
    int sinceInSeconds = since.millisecondsSinceEpoch ~/ 1000;
    return _select(whereStmt: 'WHERE timestamp >= $sinceInSeconds');
  }

  //todo this should not work like this. it'll just load everything into mem.
  List<BackupModel> _paged(page, {String? whereStmt}) {
    List<BackupModel> pagedBackups = _select(page: page, whereStmt: whereStmt);
    if (pagedBackups.length == 100) pagedBackups.addAll(_paged(page + 1));
    return pagedBackups;
  }

  List<BackupModel> _select({int page = 0, String? whereStmt}) {
    ResultSet results = _db.select('''
        SELECT 
          $table.id as 'bkp.id',
          $table.signature as 'bkp.signature',
          $table.timestamp as 'bkp.timestamp',
          $table.assef_ref as 'bkp.asset_ref'
        FROM $table as backup
        ${whereStmt ?? 'WHERE 1=1'}
        ''');
    List<BackupModel> backups = [];
    for (final Row row in results) {
      Map<String, dynamic> bkpMap = {
        'id': row['bkp.id'],
        'signature': row['bkp.signature'],
        'timestamp': row['bkp.timestamp'],
        'asset_ref': row['asset_ref']
      };
      BackupModel bkp = BackupModel.fromMap(bkpMap);
      backups.add(bkp);
    }
    return backups;
  }
}
