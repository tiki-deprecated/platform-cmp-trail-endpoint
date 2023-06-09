/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:typed_data';

import 'package:sqlite3/common.dart';

import '../../node/transaction/transaction_repository.dart';
import '../../utils/bytes.dart';
import '../license/license_repository.dart';
import '../payable/payable_repository.dart';
import 'receipt_model.dart';

/// The repository for [ReceiptModel] persistence.
class ReceiptRepository {
  final CommonDatabase _db;
  static const table = 'receipt_record';
  static const columnPayable = 'payable';
  static const columnAmount = 'amount';
  static const columnDescription = 'description';
  static const columnTransactionId = 'transaction_id';
  static const columnReference = 'reference';

  /// Builds a [LicenseRepository] that will use [_db] for persistence.
  ///
  /// Calls [_createTable] to ensure the table exists.
  ReceiptRepository(this._db) {
    _createTable();
  }

  /// Creates the [PayableRepository.table] if it does not exist.
  void _createTable() => _db.execute('''
    CREATE TABLE IF NOT EXISTS $table (
     $columnTransactionId BLOB PRIMARY KEY,
     $columnPayable BLOB,
     $columnAmount TEXT,
     $columnDescription TEXT,
     $columnReference TEXT,
     FOREIGN KEY($columnPayable) 
      REFERENCES ${PayableRepository.table}(${PayableRepository.columnTransactionId}),
     FOREIGN KEY($columnTransactionId) 
      REFERENCES ${TransactionRepository.table}(${TransactionRepository.columnId})
      );
    ''');

  /// Persists [payable] in [_db].
  void save(ReceiptModel receipt) {
    Map map = receipt.toMap();
    _db.execute('''
    INSERT INTO $table 
    VALUES ( ?, ?, ?, ?, ?);
    ''', [
      map[columnTransactionId],
      map[columnPayable],
      map[columnAmount],
      map[columnDescription],
      map[columnReference]
    ]);
  }

  /// Gets the [ReceiptModel] by [id] from the database.
  ReceiptModel? getById(Uint8List id) {
    List<ReceiptModel> receipts = _select(
        whereStmt: "WHERE $columnTransactionId = x'${Bytes.hexEncode(id)}'");
    return receipts.isNotEmpty ? receipts.first : null;
  }

  /// Gets all [PayableModel]s for a [payable]
  List<ReceiptModel> getByPayable(Uint8List payable) {
    String where = '''WHERE $columnPayable = 
      x'${Bytes.hexEncode(payable)}' ORDER BY $table.oid DESC''';
    return _select(whereStmt: where, params: []);
  }

  List<ReceiptModel> _select({String? whereStmt, List params = const []}) {
    ResultSet results = _db.select('''
      SELECT * FROM $table
      ${whereStmt ?? ''};
      ''', params);
    return _toReceipt(results);
  }

  List<ReceiptModel> _toReceipt(ResultSet results) {
    List<ReceiptModel> receipts = [];
    for (final Row row in results) {
      Map<String, dynamic> map = {
        columnTransactionId: row[columnTransactionId],
        columnPayable: row[columnPayable],
        columnAmount: row[columnAmount],
        columnDescription: row[columnDescription],
        columnReference: row[columnReference]
      };
      ReceiptModel license = ReceiptModel.fromMap(map);
      receipts.add(license);
    }
    return receipts;
  }
}
