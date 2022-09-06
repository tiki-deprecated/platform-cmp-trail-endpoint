import 'dart:convert';

import 'package:sqlite3/sqlite3.dart';

import '../../utils/page_model.dart';
import '../xchain/xchain_model.dart';
import '../xchain/xchain_repository.dart';
import 'block_model.dart';

class BlockRepository {
  static const table = 'block';
  static const xchainTable = XchainRepository.table;
  static const collumnSeq = 'seq';
  static const collumnId = 'id';
  static const collumnVersion = 'version';
  static const collumnPreviousHash = 'previous_hash';
  static const collumnXchainAddress = 'xchain_id';
  static const collumnTransactionRoot = 'transaction_root';
  static const collumnTransactionCount = 'transaction_count';
  static const collumnTimestamp = 'timestamp';

  final Database _db;

  BlockRepository(this._db) {
    createTable();
  }

  void createTable() async {
    _db.execute('''
      CREATE TABLE IF NOT EXISTS $table (
        $collumnSeq INTEGER AUTO INCREMENT,
        $collumnId TEXT PRIMARY KEY,
        $collumnVersion INTEGER NOT NULL,
        $collumnPreviousHash TEXT,
        $collumnXchainAddress TEXT,
        $collumnTransactionRoot BLOB,
        $collumnTransactionCount INTEGER,
        $collumnTimestamp INTEGER,

      );
    ''');
  }

  void save(BlockModel block) {
    _db.execute('''INSERT INTO $table VALUES (
      ${block.seq},
      '${base64.encode([...block.id!])}',
      ${block.version},
      '${base64.encode([...block.previousHash])}',
      ${block.xchain == null ? null : "'${block.xchain!.address}'"},
      ${block.transactionRoot},
      ${block.transactionCount},
      ${block.timestamp}
    );''');
  }

  PageModel<BlockModel> getByChain(String address, {int page = 0}) {
    String whereStmt = 'WHERE ${XchainRepository.collumnAddress} = "$address"';
    List<BlockModel> blocks = _select(page: page, whereStmt: whereStmt);
    return PageModel<BlockModel>(page, blocks);
  }

  PageModel<BlockModel> getLocal({int page = 0}) {
    String whereStmt = 'WHERE ${XchainRepository.collumnAddress} IS NULL';
    List<BlockModel> blocks = _select(page: page, whereStmt: whereStmt);
    return PageModel<BlockModel>(page, blocks);
  }

  BlockModel? getById(String id) {
    List<BlockModel> blocks = _select(whereStmt: "WHERE blocks.id = '$id'");
    return blocks.isNotEmpty ? blocks[0] : null;
  }

  BlockModel? getLast({String? xchainIAddress}) {
    String where = xchainIAddress == null
        ? "WHERE $collumnXchainAddress IS NULL"
        : "WHERE $collumnXchainAddress = '$xchainIAddress'";
    List<BlockModel> blocks = _select(whereStmt: where, last: true);
    return blocks.isNotEmpty ? blocks.first : null;
  }

  List<BlockModel> _select(
      {int? page, String whereStmt = 'WHERE 1=1', bool last = false}) {
    String limit = page != null ? 'LIMIT ${page * 100},100' : '';
    ResultSet results = _db.select('''
        SELECT 
          $table.$collumnSeq as '$table.$collumnSeq',
          $table.$collumnId as '$table.$collumnId',
          $table.$collumnVersion as '$table.$collumnVersion',
          $table.$collumnPreviousHash as '$table.$collumnPreviousHash',
          $table.$collumnXchainAddress as '$table.$collumnXchainAddress',
          $table.$collumnTransactionRoot as '$table.$collumnTransactionRoot',
          $table.$collumnTransactionCount as '$table.$collumnTransactionCount',
          $table.$collumnTimestamp as '$table.$collumnTimestamp',
          $xchainTable.${XchainRepository.collumnAddress} as '$xchainTable.${XchainRepository.collumnAddress}',
          $xchainTable.${XchainRepository.collumnPubkey} as '$xchainTable.${XchainRepository.collumnPubkey}',
          $xchainTable.${XchainRepository.collumnLastChecked} as '$xchainTable.${XchainRepository.collumnLastChecked}'
        FROM $table
        LEFT JOIN ${XchainRepository.table} ON 
        $table.$collumnXchainAddress = $xchainTable.${XchainRepository.collumnAddress}
        $whereStmt
        ${last ? 'ORDER BY $table.$collumnSeq DESC' : ''};
        $limit
        ''');
    List<BlockModel> blocks = [];
    for (final Row row in results) {
      Map<String, dynamic> blockMap = {
        collumnSeq: row['$table.$collumnSeq'],
        collumnId: row['$table.$collumnId'],
        collumnVersion: row['$table.$collumnVersion'],
        collumnPreviousHash: row['$table.$collumnPreviousHash'],
        collumnXchainAddress: row['$table.$collumnXchainAddress'] == null
            ? null
            : XchainModel.fromMap({
              '$xchainTable.${XchainRepository.collumnAddress}' : 
                row ['$xchainTable.${XchainRepository.collumnAddress}'],
              '$xchainTable.${XchainRepository.collumnPubkey}' : 
                row ['$xchainTable.${XchainRepository.collumnPubkey}'],
              '$xchainTable.${XchainRepository.collumnLastChecked}' : 
                row ['$xchainTable.${XchainRepository.collumnLastChecked}'],
            }),
        collumnTransactionRoot: row['$table.$collumnTransactionRoot'],
        collumnTransactionCount: row['$table.$collumnTransactionCount'],
        collumnTimestamp: row['$table.$collumnTimestamp'],
      };
      BlockModel block = BlockModel.fromMap(blockMap);
      blocks.add(block);
    }
    return blocks;
  }

  Future<void> prune(BlockModel blk) async {
    _db.execute(
        "DELETE FROM $table WHERE block_id = '${base64.encode([...blk.id!])}'");
  }
}
