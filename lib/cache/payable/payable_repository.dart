/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:typed_data';

import 'package:sqlite3/common.dart';

import '../../node/transaction/transaction_repository.dart';
import '../../utils/bytes.dart';
import '../license/license_repository.dart';
import 'payable_model.dart';

/// The repository for [PayableModel] persistence.
class PayableRepository {
  final CommonDatabase _db;
  static const table = 'payable_record';
  static const columnLicense = 'license';
  static const columnAmount = 'amount';
  static const columnType = 'type';
  static const columnDescription = 'description';
  static const columnTransactionId = 'transaction_id';
  static const columnExpiry = 'expiry';
  static const columnReference = 'reference';

  /// Builds a [LicenseRepository] that will use [_db] for persistence.
  ///
  /// Calls [_createTable] to ensure the table exists.
  PayableRepository(this._db) {
    _createTable();
  }

  /// Creates the [PayableRepository.table] if it does not exist.
  void _createTable() => _db.execute('''
    CREATE TABLE IF NOT EXISTS $table (
     $columnTransactionId BLOB PRIMARY KEY,
     $columnLicense BLOB,
     $columnAmount TEXT,
     $columnType TEXT,
     $columnDescription TEXT,
     $columnExpiry INTEGER,
     $columnReference TEXT,
     FOREIGN KEY($columnLicense) 
      REFERENCES ${LicenseRepository.table}(${LicenseRepository.columnTransactionId}),
     FOREIGN KEY($columnTransactionId) 
      REFERENCES ${TransactionRepository.table}(${TransactionRepository.columnId})
      );
    ''');

  /// Persists [payable] in [_db].
  void save(PayableModel payable) {
    Map map = payable.toMap();
    _db.execute('''
    INSERT INTO $table 
    VALUES ( ?, ?, ?, ?, ?, ?, ?);
    ''', [
      map[columnTransactionId],
      map[columnLicense],
      map[columnAmount],
      map[columnType],
      map[columnDescription],
      map[columnExpiry],
      map[columnReference]
    ]);
  }

  /// Gets the [PayableModel] by [id] from the database.
  PayableModel? getById(Uint8List id) {
    List<PayableModel> payables = _select(
        whereStmt: "WHERE $columnTransactionId = x'${Bytes.hexEncode(id)}'");
    return payables.isNotEmpty ? payables.first : null;
  }

  List<PayableModel> _select({String? whereStmt, List params = const []}) {
    ResultSet results = _db.select('''
      SELECT * FROM $table
      ${whereStmt ?? ''};
      ''', params);
    return _toPayable(results);
  }

  List<PayableModel> _toPayable(ResultSet results) {
    List<PayableModel> payables = [];
    for (final Row row in results) {
      Map<String, dynamic> map = {
        columnTransactionId: row[columnTransactionId],
        columnLicense: row[columnLicense],
        columnAmount: row[columnAmount],
        columnType: row[columnType],
        columnDescription: row[columnDescription],
        columnExpiry: row[columnExpiry],
        columnReference: row[columnReference]
      };
      PayableModel license = PayableModel.fromMap(map);
      payables.add(license);
    }
    return payables;
  }
}
