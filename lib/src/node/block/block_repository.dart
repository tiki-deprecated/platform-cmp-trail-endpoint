import 'package:sqlite3/sqlite3.dart';
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
          block_id INTEGER PRIMARY KEY,
          version INTEGER NOT NULL,
          previous_hash TEXT NOT NULL,
          block_id INTEGER NOT NULL,
          transaction_root TEXT NOT NULL,
          transaction_count INTEGER NOT NULL
          timestamp INTEGER NOT NULL;
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

  List<BlockModel> getAll() {
    return _paged(0);
  }

  BlockModel? getById(int id) {
    List<BlockModel> blocks = _select(whereStmt: 'WHERE block_id = $id');
    return blocks.isNotEmpty ? blocks[0] : null;
  }

  BlockModel? getByPreviousHash(String hash) {
    List<BlockModel> blocks = _select(whereStmt: 'WHERE previous_hash = ${hash.trim()}');
    return blocks.isNotEmpty ? blocks[0] : null;
  }

  List<BlockModel> getBefore(DateTime before) {
    int beforeInSeconds = before.millisecondsSinceEpoch ~/ 1000;
    return _select(whereStmt: 'WHERE timestamp < $beforeInSeconds');
  }

  List<BlockModel> getAfter(DateTime since) {
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
        SELECT *
        FROM $table 
        ${whereStmt ?? ''}
        LIMIT $offset,100;
        ''');
    List<BlockModel> blocks = [];
    for (final Row row in results) {
      blocks.add(BlockModel.fromMap(row));
    }
    return blocks;
  }
}
