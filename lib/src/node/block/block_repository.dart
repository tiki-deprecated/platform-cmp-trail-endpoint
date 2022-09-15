import 'dart:convert';

import 'package:sqlite3/sqlite3.dart';

import 'block_model.dart';

/// The repository for [BlockModel] persistance in [Database].
class BlockRepository {
  /// The [BlockModel] table name in [_db].
  static const table = 'block';

  /// The [BlockModel.id] column.
  static const columnId = 'id';

  /// The [BlockModel.version] column.
  static const columnVersion = 'version';

  /// The [BlockModel.previousHash] column.
  static const columnPreviousHash = 'previous_hash';

  /// The [BlockModel.transactionRoot] column.
  static const columnTransactionRoot = 'transaction_root';

  /// The [BlockModel.transactionCount] column.
  static const columnTransactionCount = 'transaction_count';

  /// The [BlockModel.timestamp] column.
  static const columnTimestamp = 'timestamp';

  /// The [Database] used to persist [BlockModel].
  final Database _db;

  /// Builds a [BlockRepository] that will use [_db] for persistence.
  ///
  /// It calls [createTable] to make sure the table exists.
  BlockRepository(this._db) {
    createTable();
  }

  /// Builds a [BlockRepository] that will use [_db] for persistence.
  ///
  /// It calls [createTable] to make sure the table exists.
  void createTable() async {
    _db.execute('''
      CREATE TABLE IF NOT EXISTS $table (
        $columnId TEXT PRIMARY KEY NOT NULL,
        $columnVersion INTEGER NOT NULL,
        $columnPreviousHash TEXT,
        $columnTransactionRoot BLOB,
        $columnTransactionCount INTEGER,
        $columnTimestamp INTEGER
      );
    ''');
  }

  /// Persists a [block] in the local [_db].
  void save(BlockModel block) {
    List<dynamic> params = [
      base64.encode([...block.id!]),
      block.version,
      base64.encode([...block.previousHash]),
      block.transactionRoot,
      block.transactionCount,
      block.timestamp.millisecondsSinceEpoch ~/ 1000
    ];
    _db.execute('INSERT INTO $table VALUES (?, ?, ?, ?, ?, ?);', params);
  }

  /// Gets a [BlockModel] by its [BlockModel.id].
  BlockModel? getById(String id) {
    List<BlockModel> blocks =
        _select(whereStmt: "WHERE $table.$columnId = '$id'");
    return blocks.isNotEmpty ? blocks[0] : null;
  }

  /// Gets the last persisted [BlockModel].
  BlockModel? getLast() {
    List<BlockModel> blocks = _select(last: true);
    return blocks.isNotEmpty ? blocks.first : null;
  }

  List<BlockModel> _select(
      {int? page, String whereStmt = 'WHERE 1=1', bool last = false}) {
    String limit = page != null ? 'LIMIT ${page * 100},100' : '';
    ResultSet results = _db.select('''
        SELECT 
          $table.$columnId as '$table.$columnId',
          $table.$columnVersion as '$table.$columnVersion',
          $table.$columnPreviousHash as '$table.$columnPreviousHash',
          $table.$columnTransactionRoot as '$table.$columnTransactionRoot',
          $table.$columnTransactionCount as '$table.$columnTransactionCount',
          $table.$columnTimestamp as '$table.$columnTimestamp'
        FROM $table
        $whereStmt
        ${last ? 'ORDER BY $table.$columnTimestamp DESC' : ''};
        $limit
        ''');
    List<BlockModel> blocks = [];
    for (final Row row in results) {
      Map<String, dynamic> blockMap = {
        columnId: base64.decode(row['$table.$columnId']),
        columnVersion: row['$table.$columnVersion'],
        columnPreviousHash: base64.decode(row['$table.$columnPreviousHash']),
        columnTransactionRoot: row['$table.$columnTransactionRoot'],
        columnTransactionCount: row['$table.$columnTransactionCount'],
        columnTimestamp: row['$table.$columnTimestamp'],
      };
      BlockModel block = BlockModel.fromMap(blockMap);
      blocks.add(block);
    }
    return blocks;
  }
}
