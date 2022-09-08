import 'dart:convert';

import 'package:sqlite3/sqlite3.dart';

import '../../utils/page_model.dart';
import 'block_model.dart';

class BlockRepository {
  static const table = 'block';

  static const columnSeq = 'seq';
  static const columnId = 'id';
  static const columnVersion = 'version';
  static const columnPreviousHash = 'previous_hash';
  static const columnTransactionRoot = 'transaction_root';
  static const columnTransactionCount = 'transaction_count';
  static const columnTimestamp = 'timestamp';

  final Database _db;

  BlockRepository(this._db) {
    createTable();
  }

  void createTable() async {
    _db.execute('''
      CREATE TABLE IF NOT EXISTS $table (
        $columnSeq INTEGER AUTO INCREMENT,
        $columnId TEXT PRIMARY KEY NOT NULL,
        $columnVersion INTEGER NOT NULL,
        $columnPreviousHash TEXT,
        $columnTransactionRoot BLOB,
        $columnTransactionCount INTEGER,
        $columnTimestamp INTEGER
      );
    ''');
  }

  void save(BlockModel block) {
    _db.execute('INSERT INTO $table VALUES (?, ?, ?, ?, ?, ?, ?);', [
      block.seq,
      base64.encode([...block.id!]),
      block.version,
      base64.encode([...block.previousHash]),
      block.transactionRoot,
      block.transactionCount,
      block.timestamp.millisecondsSinceEpoch ~/ 1000
    ]);
  }

  PageModel<BlockModel> getLocal({int page = 0}) {
    // String whereStmt = 'WHERE ${XchainRepository.columnAddress} IS NULL';
    List<BlockModel> blocks = _select(page: page);
    return PageModel<BlockModel>(page, blocks);
  }

  BlockModel? getById(String id) {
    List<BlockModel> blocks =
        _select(whereStmt: "WHERE $table.$columnId = '$id'");
    return blocks.isNotEmpty ? blocks[0] : null;
  }

  BlockModel? getLast({String? xchainIAddress}) {
    // String where = xchainIAddress == null
    //     ? "WHERE $columnXchainAddress IS NULL"
    //     : "WHERE $columnXchainAddress = '$xchainIAddress'";
    List<BlockModel> blocks = _select(last: true);
    return blocks.isNotEmpty ? blocks.first : null;
  }

  List<BlockModel> _select(
      {int? page, String whereStmt = 'WHERE 1=1', bool last = false}) {
    String limit = page != null ? 'LIMIT ${page * 100},100' : '';
    ResultSet results = _db.select('''
        SELECT 
          $table.$columnSeq as '$table.$columnSeq',
          $table.$columnId as '$table.$columnId',
          $table.$columnVersion as '$table.$columnVersion',
          $table.$columnPreviousHash as '$table.$columnPreviousHash',
          $table.$columnTransactionRoot as '$table.$columnTransactionRoot',
          $table.$columnTransactionCount as '$table.$columnTransactionCount',
          $table.$columnTimestamp as '$table.$columnTimestamp'
        FROM $table
        $whereStmt
        ${last ? 'ORDER BY $table.$columnSeq DESC' : ''};
        $limit
        ''');
    List<BlockModel> blocks = [];
    for (final Row row in results) {
      Map<String, dynamic> blockMap = {
        columnSeq: row['$table.$columnSeq'],
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

  Future<void> prune(BlockModel blk) async {
    _db.execute("DELETE FROM $table WHERE block_id = ?;", [
      base64.encode([...blk.id!])
    ]);
  }
}
