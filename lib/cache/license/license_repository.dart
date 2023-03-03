/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:typed_data';

import 'package:sqlite3/sqlite3.dart';

import '../../node/transaction/transaction_repository.dart';
import '../../utils/bytes.dart';
import 'license_model.dart';

/// The repository for [LicenseModel] persistence.
class LicenseRepository {
  final Database _db;
  static const table = 'license_record';
  static const columnTitle = 'title';
  static const columnUses = 'uses';
  static const columnTerms = 'terms';
  static const columnDescription = 'description';
  static const columnTransactionId = 'transaction_id';
  static const columnExpiry = 'expiry';

  /// Builds a [LicenseRepository] that will use [_db] for persistence.
  ///
  /// Calls [_createTable] to ensure the table exists.
  LicenseRepository(this._db) {
    _createTable();
  }

  /// Creates the [LicenseRepository.table] if it does not exist.
  void _createTable() => _db.execute('''
    CREATE TABLE IF NOT EXISTS $table (
     $columnTransactionId BLOB PRIMARY KEY,
     $columnTitle BLOB,
     $columnUses TEXT,
     $columnTerms TEXT,
     $columnDescription TEXT,
     $columnExpiry INTEGER,
     FOREIGN KEY($columnTitle) 
      REFERENCES ${LicenseRepository.table}(${LicenseRepository.columnTransactionId}),
     FOREIGN KEY($columnTransactionId) 
      REFERENCES ${TransactionRepository.table}(${TransactionRepository.columnId})
      );
    ''');

  /// Persists [license] in [_db].
  void save(LicenseModel license) {
    Map map = license.toMap();
    _db.execute('''
    INSERT INTO $table 
    VALUES ( ?, ?, ?, ?, ?, ?);
    ''', [
      map[columnTransactionId],
      map[columnTitle],
      jsonEncode(map[columnUses]),
      map[columnTerms],
      map[columnDescription],
      map[columnExpiry]
    ]);
  }

  /// Gets the latest [LicenseModel] by [title] from the database.
  LicenseModel? getLatestByTitle(Uint8List title) {
    String where = '''WHERE $columnTitle = 
      x'${Bytes.hexEncode(title)}' ORDER BY $table.oid DESC LIMIT 1''';
    List<LicenseModel> licenses = _select(whereStmt: where, params: []);
    return licenses.isNotEmpty ? licenses.first : null;
  }

  /// Gets all [LicenseModel] for a [title] from the database.
  List<LicenseModel> getAllByTitle(Uint8List title) {
    String where = '''WHERE $columnTitle = 
      x'${Bytes.hexEncode(title)}' ORDER BY $table.oid DESC''';
    return _select(whereStmt: where, params: []);
  }

  /// Gets the [LicenseModel] by [id] from the database.
  LicenseModel? getById(Uint8List id) {
    List<LicenseModel> licenses = _select(
        whereStmt: "WHERE $columnTransactionId = x'${Bytes.hexEncode(id)}'");
    return licenses.isNotEmpty ? licenses.first : null;
  }

  List<LicenseModel> _select({String? whereStmt, List params = const []}) {
    ResultSet results = _db.select('''
      SELECT * FROM $table
      ${whereStmt ?? ''};
      ''', params);
    List<LicenseModel> licenses = [];
    for (final Row row in results) {
      Map<String, dynamic> map = {
        columnTransactionId: row[columnTransactionId],
        columnTitle: row[columnTitle],
        columnUses: jsonDecode(row[columnUses]),
        columnTerms: row[columnTerms],
        columnDescription: row[columnDescription],
        columnExpiry: row[columnExpiry]
      };
      LicenseModel license = LicenseModel.fromMap(map);
      licenses.add(license);
    }
    return licenses;
  }
}
