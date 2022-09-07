import 'dart:convert';
import 'dart:typed_data';

import 'package:sqlite3/sqlite3.dart';

import '../block/block_repository.dart';
import 'transaction_model.dart';

class TransactionRepository {
  static const table = 'transaction';
  static const collumnSeq = 'seq';
  static const collumnId = 'id';
  static const collumnMerkelProof = 'merkel_proof';
  static const collumnVersion = 'version';
  static const collumnAddress = 'address';
  static const collumnContents = 'contents';
  static const collumnAssetRef = 'asset_ref';
  static const collumnBlockId = 'block_id';
  static const collumnTimestamp = 'timestamp';
  static const collumnSignature = 'signature';

  final Database _db;

  TransactionRepository(this._db) {
    createTable();
  }

  Future<void> createTable() async {
    _db.execute('''
      CREATE TABLE IF NOT EXISTS $table (
          $collumnSeq INTEGER AUTO INCREMENT,
          $collumnId STRING PRIMARY KEY,
          $collumnMerkelProof BLOB,
          $collumnVersion INTEGER NOT NULL,
          $collumnAddress BLOB NOT NULL,
          $collumnContents BLOB NOT NULL,
          $collumnAssetRef TEXT NOT NULL,
          $collumnBlockId TEXT, 
          $collumnTimestamp INTEGER NOT NULL,
          $collumnSignature TEXT NOT NULL
      );
    ''');
  }

  TransactionModel save(TransactionModel transaction) {
    _db.execute('''INSERT INTO $table VALUES (
      ${transaction.seq},
      ${base64.encode(transaction.id!)},
      ${transaction.merkelProof},
      ${transaction.version},
      ${transaction.address},
      ${transaction.contents},
      ${transaction.assetRef},
      ${transaction.block == null ? null : "'${transaction.block!.id}'"},
      ${transaction.timestamp},
      ${transaction.signature}
       );''');
    transaction.seq = _db.lastInsertRowId;
    return transaction;
  }

  TransactionModel commit(TransactionModel transaction) {
    _db.execute('''UPDATE $table SET
        $collumnMerkelProof = ${transaction.merkelProof}, 
        $collumnBlockId = ${base64.encode(transaction.block!.id!)}
        WHERE $collumnId = '${base64.encode(transaction.id!)}';  
        ''');
    return getById(base64.encode(transaction.id!))!;
  }

  List<TransactionModel> getByBlockId(Uint8List blockId) {
    String whereStmt = 'WHERE block_id = "${base64.encode(blockId)}"';
    return _select(whereStmt: whereStmt);
  }

  List<TransactionModel> getPending() {
    String whereStmt = 'WHERE block_id IS NULL';
    return _select(whereStmt: whereStmt);
  }

  TransactionModel? getById(String id) {
    List<TransactionModel> transactions =
        _select(whereStmt: "WHERE transactions.id = '$id'");
    return transactions.isNotEmpty ? transactions[0] : null;
  }

  Future<void> prune(Uint8List id) async {
    _db.execute('DELETE FROM $table WHERE id = "${base64.encode(id)}""');
  }

  List<TransactionModel> _select({int? page, String? whereStmt}) {
    String blockTable = BlockRepository.table;
    // String xchainTable = XchainRepository.table;
    ResultSet results = _db.select('''
        SELECT 
          $table.$collumnId as '$table.$collumnId',
          $table.$collumnSeq as '$table.$collumnSeq',
          $table.$collumnVersion as '$table.$collumnVersion',
          $table.$collumnAddress as '$table.$collumnAddress',
          $table.$collumnContents as '$table.$collumnContents',
          $table.$collumnAssetRef as '$table.$collumnAssetRef',
          $table.$collumnMerkelProof as '$table.$collumnMerkelProof',
          $table.$collumnBlockId as '$table.$collumnBlockId',
          $table.$collumnTimestamp as '$table.$collumnTimestamp',
          $table.$collumnSignature as '$table.$collumnSignature',
          $blockTable.${BlockRepository.collumnSeq} as '$blockTable.${BlockRepository.collumnSeq}',
          $blockTable.${BlockRepository.collumnId} as '$blockTable.${BlockRepository.collumnId}',
          $blockTable.${BlockRepository.collumnVersion} as '$blockTable.${BlockRepository.collumnVersion}',
          $blockTable.${BlockRepository.collumnPreviousHash} as '$blockTable.${BlockRepository.collumnPreviousHash}',
          $blockTable.${BlockRepository.collumnTransactionRoot} as '$blockTable.${BlockRepository.collumnTransactionRoot}',
          $blockTable.${BlockRepository.collumnTransactionCount} as '$blockTable.${BlockRepository.collumnTransactionCount}',
          $blockTable.${BlockRepository.collumnTimestamp} as '$blockTable.${BlockRepository.collumnTimestamp}',
        FROM $table
        LEFT JOIN $blockTable
        ON $table.$collumnBlockId = $blockTable.$BlockRepository.collumnId
        ${whereStmt ?? ''}
        ${page == null ? '' : 'LIMIT ${page * 100},100'};
        ''');
    List<TransactionModel> transactions = [];
    for (final Row row in results) {
      Map<String, dynamic>? blockMap =
          row['$blockTable.${BlockRepository.collumnId}'] == null
              ? null
              : {
                  BlockRepository.collumnSeq:
                      row['$blockTable.${BlockRepository.collumnSeq}'],
                  BlockRepository.collumnId:
                      row['$blockTable.${BlockRepository.collumnId}'],
                  BlockRepository.collumnVersion:
                      row['$blockTable.${BlockRepository.collumnVersion}'],
                  BlockRepository.collumnPreviousHash:
                      row['$blockTable.${BlockRepository.collumnPreviousHash}'],
                  BlockRepository.collumnTransactionRoot:
                      row['$table.${BlockRepository.collumnTransactionRoot}'],
                  BlockRepository.collumnTransactionCount:
                      row['$table.${BlockRepository.collumnTransactionCount}'],
                  BlockRepository.collumnTimestamp:
                      row['$table.$collumnTimestamp'],
                };
      Map<String, dynamic>? transactionMap = {
        collumnSeq: row['$table.$collumnSeq}'],
        collumnId: row['$table.$collumnId}'],
        collumnMerkelProof: row['$table.$collumnMerkelProof}'],
        collumnVersion: row['$table.$collumnVersion}'],
        collumnAddress: row['$table.$collumnAddress}'],
        collumnContents: row['$table.$collumnContents}'],
        collumnAssetRef: row['$table.$collumnAssetRef}'],
        'block': blockMap,
        collumnTimestamp: row['$table.$collumnTimestamp}'],
        collumnSignature: row['$table.$collumnSignature}'],
      };
      TransactionModel transaction = TransactionModel.fromMap(transactionMap);
      transactions.add(transaction);
    }
    return transactions;
  }
}
