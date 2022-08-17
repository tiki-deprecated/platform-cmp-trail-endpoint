import 'package:sqlite3/sqlite3.dart';
import '../xchain/xchain_model.dart';
import '../xchain/xchain_repository.dart';
import 'block_model.dart';

class BlockRepository {
  static const table = 'blocks';
  final Database _db;

  BlockRepository(this._db) {
    createTable();
  }

  void createTable() async {
    _db.execute('''
      CREATE TABLE IF NOT EXISTS $table (
          id INTEGER PRIMARY KEY,
          version INTEGER NOT NULL,
          previous_hash TEXT NOT NULL UNIQUE,
          xchain_id INTEGER NOT NULL,
          transaction_root TEXT NOT NULL,
          transaction_count INTEGER NOT NULL,
          timestamp INTEGER NOT NULL
      );
    ''');
  }

  void save(BlockModel block) {
    try {
      _db.execute("INSERT INTO $table VALUES (${block.toSqlValues()});");
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  List<BlockModel> getAll(XchainModel xchainModel) {
    String whereStmt = 'WHERE xchain_id = ${xchainModel.id}';
    return _paged(0, whereStmt: whereStmt);
  }

  BlockModel? getById(int id) {
    List<BlockModel> blocks = _select(whereStmt: 'WHERE block_id = $id');
    return blocks.isNotEmpty ? blocks[0] : null;
  }

  BlockModel? getByPreviousHash(String hash) {
    List<BlockModel> blocks =
        _select(whereStmt: 'WHERE previous_hash = ${hash.trim()}');
    return blocks.isNotEmpty ? blocks[0] : null;
  }

  List<BlockModel> getBefore(DateTime before, XchainModel xchain) {
    int beforeInSeconds = before.millisecondsSinceEpoch ~/ 1000;
    return _select(whereStmt: 'WHERE timestamp < $beforeInSeconds');
  }

  List<BlockModel> getAfter(DateTime since, XchainModel xchain) {
    int sinceInSeconds = since.millisecondsSinceEpoch ~/ 1000;
    return _select(whereStmt: 'WHERE last_checked >= $sinceInSeconds');
  }

  List<BlockModel> _paged(page, {String? whereStmt}) {
    List<BlockModel> pagedBlocks = _select(page: page, whereStmt: whereStmt);
    if (pagedBlocks.length == 100) pagedBlocks.addAll(_paged(page + 1));
    return pagedBlocks;
  }

  // TODO verificar where sem ser raw
  List<BlockModel> _select({int page = 0, String? whereStmt}) {
    int offset = page * 100;
    ResultSet results = _db.select('''
        SELECT 
          blocks.id as 'blocks.id',
          blocks.version as 'blocks.version',
          blocks.previous_hash as 'blocks.previous_hash',
          blocks.xchain_id as 'blocks.xchain_id',
          blocks.transaction_root as 'blocks.transaction_root',
          blocks.transaction_count as 'blocks.transaction_count',
          blocks.timestamp as 'blocks.timestamp',
          xchains.id as 'xchains.id',
          xchains.last_checked as 'xchains.last_checked',
          xchains.uri as 'xchains.uri'
        FROM $table as blocks
        INNER JOIN ${XchainRepository.table} as xchains
        ON blocks.xchain_id = xchains.id
        ${whereStmt ?? ''}
        LIMIT $offset,100;
        ''');
    List<BlockModel> blocks = [];
    for (final Row row in results) {
      Map<String, dynamic> blockMap = {
        'id': row['blocks.id'],
        'version': row['blocks.version'],
        'previous_hash': row['blocks.previous_hash'],
        'transaction_root': row['blocks.transaction_root'],
        'transaction_count': row['blocks.transaction_count'],
        'timestamp': row['blocks.timestamp']
      };
      blockMap['xchain'] = XchainModel.fromMap({
        'id': row['xchains.id'],
        'last_checked': row['xchains.last_checked'],
        'uri': row['xchains.uri'],
      });
      BlockModel block = BlockModel.fromMap(blockMap);
      blocks.add(block);
    }
    return blocks;
  }
}
