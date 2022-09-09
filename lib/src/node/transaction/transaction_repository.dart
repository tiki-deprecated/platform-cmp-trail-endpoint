import 'dart:convert';
import 'dart:typed_data';

import 'package:sqlite3/sqlite3.dart';

import '../block/block_model.dart';
import '../block/block_repository.dart';
import 'transaction_model.dart';

class TransactionRepository {
  static const table = 'txn';
  static const columnSeq = 'seq';
  static const columnId = 'id';
  static const columnMerkelProof = 'merkel_proof';
  static const columnVersion = 'version';
  static const columnAddress = 'address';
  static const columnContents = 'contents';
  static const columnAssetRef = 'asset_ref';
  static const columnBlockId = 'block_id';
  static const columnTimestamp = 'timestamp';
  static const columnSignature = 'signature';

  final Database _db;

  TransactionRepository(this._db) {
    createTable();
  }

  Future<void> createTable() async {
    _db.execute('''CREATE TABLE IF NOT EXISTS $table (
          $columnSeq INTEGER AUTO INCREMENT,
          $columnId STRING PRIMARY KEY NOT NULL,
          $columnMerkelProof BLOB,
          $columnVersion INTEGER NOT NULL,
          $columnAddress BLOB NOT NULL,
          $columnContents BLOB NOT NULL,
          $columnAssetRef TEXT NOT NULL,
          $columnBlockId TEXT, 
          $columnTimestamp INTEGER NOT NULL,
          $columnSignature TEXT NOT NULL
      );
    ''');
  }

  TransactionModel save(TransactionModel transaction) {
    int timestamp = transaction.timestamp.millisecondsSinceEpoch ~/ 1000;
    _db.execute('INSERT INTO $table VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?);', [
      transaction.seq,
      base64.encode(transaction.id!),
      transaction.merkelProof,
      transaction.version,
      transaction.address,
      transaction.contents,
      transaction.assetRef,
      transaction.block == null ? null : "'${transaction.block!.id}'",
      timestamp,
      transaction.signature,
    ]);
    transaction.seq = _db.lastInsertRowId;
    return transaction;
  }

  addAll(List<TransactionModel> txns) {
    List params = [];
    String insert = 'INSERT INTO $table VALUES ';
    for (int i = 0; i < txns.length; i++) {
      TransactionModel transaction = txns[i];
      insert = '$insert (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)';
      params.addAll([
        transaction.seq,
        base64.encode(transaction.id!),
        transaction.merkelProof,
        transaction.version,
        transaction.address,
        transaction.contents,
        transaction.assetRef,
        transaction.block == null ? null : "'${transaction.block!.id}'",
        transaction.timestamp.millisecondsSinceEpoch ~/ 1000,
        transaction.signature
      ]);
      if (i < txns.length - 1) insert = '$insert, ';
    }
  }

  TransactionModel commit(TransactionModel transaction) {
    _db.execute(
        '''UPDATE $table SET $columnMerkelProof = ?,  $columnBlockId = ? 
      WHERE $columnId = ? ''',
        [
          transaction.merkelProof,
          base64.encode(transaction.block!.id!),
          base64.encode(transaction.id!)
        ]);
    return getById(base64.encode(transaction.id!))!;
  }

  List<TransactionModel> getByBlockId(Uint8List blockId) {
    String whereStmt = 'WHERE $columnBlockId = "${base64.encode(blockId)}"';
    return _select(whereStmt: whereStmt);
  }

  List<TransactionModel> getPending() {
    String whereStmt = 'WHERE $columnBlockId IS NULL';
    return _select(whereStmt: whereStmt);
  }

  TransactionModel? getById(String id) {
    List<TransactionModel> transactions =
        _select(whereStmt: "WHERE $table.$columnId = '$id'");
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
          $table.$columnId as '$table.$columnId',
          $table.$columnSeq as '$table.$columnSeq',
          $table.$columnVersion as '$table.$columnVersion',
          $table.$columnAddress as '$table.$columnAddress',
          $table.$columnContents as '$table.$columnContents',
          $table.$columnAssetRef as '$table.$columnAssetRef',
          $table.$columnMerkelProof as '$table.$columnMerkelProof',
          $table.$columnBlockId as '$table.$columnBlockId',
          $table.$columnTimestamp as '$table.$columnTimestamp',
          $table.$columnSignature as '$table.$columnSignature',
          $blockTable.${BlockRepository.columnSeq} as '$blockTable.${BlockRepository.columnSeq}',
          $blockTable.${BlockRepository.columnId} as '$blockTable.${BlockRepository.columnId}',
          $blockTable.${BlockRepository.columnVersion} as '$blockTable.${BlockRepository.columnVersion}',
          $blockTable.${BlockRepository.columnPreviousHash} as '$blockTable.${BlockRepository.columnPreviousHash}',
          $blockTable.${BlockRepository.columnTransactionRoot} as '$blockTable.${BlockRepository.columnTransactionRoot}',
          $blockTable.${BlockRepository.columnTransactionCount} as '$blockTable.${BlockRepository.columnTransactionCount}',
          $blockTable.${BlockRepository.columnTimestamp} as '$blockTable.${BlockRepository.columnTimestamp}'
        FROM $table
        LEFT JOIN $blockTable
        ON $table.$columnBlockId = $blockTable.${BlockRepository.columnId}
        ${whereStmt ?? ''}
        ${page == null ? '' : 'LIMIT ${page * 100},100'};
        ''');
    List<TransactionModel> transactions = [];
    for (final Row row in results) {
      Map<String, dynamic>? blockMap = row[
                  '$blockTable.${BlockRepository.columnId}'] ==
              null
          ? null
          : {
              BlockRepository.columnSeq:
                  row['$blockTable.${BlockRepository.columnSeq}'],
              BlockRepository.columnId:
                  base64.decode(row['$blockTable.${BlockRepository.columnId}']),
              BlockRepository.columnVersion:
                  row['$blockTable.${BlockRepository.columnVersion}'],
              BlockRepository.columnPreviousHash: base64.decode(
                  row['$blockTable.${BlockRepository.columnPreviousHash}']),
              BlockRepository.columnTransactionRoot:
                  row['$blockTable.${BlockRepository.columnTransactionRoot}'],
              BlockRepository.columnTransactionCount:
                  row['$blockTable.${BlockRepository.columnTransactionCount}'],
              BlockRepository.columnTimestamp:
                  row['$blockTable.$columnTimestamp'],
            };
      Map<String, dynamic>? transactionMap = {
        columnSeq: row['$table.$columnSeq'],
        columnId: base64.decode(row['$table.$columnId']),
        columnMerkelProof: row['$table.$columnMerkelProof'],
        columnVersion: row['$table.$columnVersion'],
        columnAddress: row['$table.$columnAddress'],
        columnContents: row['$table.$columnContents'],
        columnAssetRef: row['$table.$columnAssetRef'],
        'block': blockMap != null ? BlockModel.fromMap(blockMap) : null,
        columnTimestamp: row['$table.$columnTimestamp'],
        columnSignature: row['$table.$columnSignature'],
      };
      TransactionModel transaction = TransactionModel.fromMap(transactionMap);
      transactions.add(transaction);
    }
    return transactions;
  }
}
