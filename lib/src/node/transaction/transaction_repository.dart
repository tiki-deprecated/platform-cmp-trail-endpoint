import 'dart:convert';
import 'dart:typed_data';

import 'package:sqlite3/sqlite3.dart';

import '../block/block_model.dart';
import '../block/block_repository.dart';
import 'transaction_model.dart';

/// The repository for [TransactionModel] persistance in [Database].
class TransactionRepository {
  /// The [TrasactionModel] table name in [_db].
  ///
  /// It could not be 'transaction' to avoid protected terms usage in sqlite.
  static const table = 'txn';

  /// The [TransactionModel.id] column.
  static const columnId = 'id';

  /// The [TransactionModel.merkelProof] column.
  static const columnMerkelProof = 'merkel_proof';

  /// The [TransactionModel.version] column.
  static const columnVersion = 'version';

  /// The [TransactionModel.address] column.
  static const columnAddress = 'address';

  /// The [TransactionModel.contents] column.
  static const columnContents = 'contents';

  /// The [TransactionModel.assetPef] column.
  static const columnAssetRef = 'asset_ref';

  /// The [TransactionModel.block.id] column.
  static const columnBlockId = 'block_id';

  /// The [TransactionModel.timestamp] column.
  static const columnTimestamp = 'timestamp';

  /// The [TransactionModel.signature] column.
  static const columnSignature = 'signature';

  /// The [Database] used to persist [TransactionModel].
  final Database _db;

  /// Builds a [TransactionRepository] that will use [_db] for persistence.
  ///
  /// It calls [createTable] to make sure the table exists.
  TransactionRepository(this._db) {
    createTable();
  }

  /// Creates the [TransactionRepository.table] if it does not exist.
  Future<void> createTable() async {
    _db.execute('''CREATE TABLE IF NOT EXISTS $table (
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

  /// Persists a [transaction] in [_db].
  TransactionModel save(TransactionModel transaction) {
    int timestamp = transaction.timestamp.millisecondsSinceEpoch ~/ 1000;
    _db.execute('INSERT INTO $table VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?);', [
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
    return transaction;
  }

  /// Commits the [transaction] by saving its [TransactionModel.merkelProof] and
  /// [TransactionModel.block]
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

  /// Gets the [List] of [TransactionModel] from the [BlockModel] from its [blockId].
  List<TransactionModel> getByBlockId(Uint8List blockId) {
    String whereStmt = 'WHERE $columnBlockId = "${base64.encode(blockId)}"';
    return _select(whereStmt: whereStmt);
  }

  /// Gets all the transactions that were not commited yet. See [commit].
  List<TransactionModel> getPending() {
    String whereStmt = 'WHERE $columnBlockId IS NULL';
    return _select(whereStmt: whereStmt);
  }

  /// Gets a transaction by its [id].
  TransactionModel? getById(String id) {
    List<TransactionModel> transactions =
        _select(whereStmt: "WHERE $table.$columnId = '$id'");
    return transactions.isNotEmpty ? transactions[0] : null;
  }

  List<TransactionModel> _select({int? page, String? whereStmt}) {
    String blockTable = BlockRepository.table;
    // String xchainTable = XchainRepository.table;
    ResultSet results = _db.select('''
        SELECT 
          $table.$columnId as '$table.$columnId',
          $table.$columnVersion as '$table.$columnVersion',
          $table.$columnAddress as '$table.$columnAddress',
          $table.$columnContents as '$table.$columnContents',
          $table.$columnAssetRef as '$table.$columnAssetRef',
          $table.$columnMerkelProof as '$table.$columnMerkelProof',
          $table.$columnBlockId as '$table.$columnBlockId',
          $table.$columnTimestamp as '$table.$columnTimestamp',
          $table.$columnSignature as '$table.$columnSignature',
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
