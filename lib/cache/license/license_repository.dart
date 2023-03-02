/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:typed_data';

import 'package:sqlite3/sqlite3.dart';

import '../../node/transaction/transaction_repository.dart';
import '../../utils/bytes.dart';
import 'license_record.dart';

class LicenseRepository {
  final Database _db;
  static const table = 'license_record';
  static const columnTitle = 'title';
  static const columnUses = 'uses';
  static const columnTerms = 'terms';
  static const columnDescription = 'description';
  static const columnTransactionId = 'transaction_id';
  static const columnExpiry = 'expiry';

  LicenseRepository(this._db) {
    _createTable();
  }

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

  void save(LicenseRecord license) {
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

  LicenseRecord? getByTitle(Uint8List title) {
    String where = '''WHERE $columnTitle = 
      x'${Bytes.hexEncode(title)}' ORDER BY $table.oid DESC LIMIT 1''';
    List<LicenseRecord> licenses = _select(whereStmt: where, params: []);
    return licenses.isNotEmpty ? licenses.first : null;
  }

  List<LicenseRecord> _select({String? whereStmt, List params = const []}) {
    ResultSet results = _db.select('''
      SELECT * FROM $table
      ${whereStmt ?? ''};
      ''', params);
    List<LicenseRecord> licenses = [];
    for (final Row row in results) {
      Map<String, dynamic> map = {
        columnTransactionId: row[columnTransactionId],
        columnTitle: row[columnTitle],
        columnUses: jsonDecode(row[columnUses]),
        columnTerms: row[columnTerms],
        columnDescription: row[columnDescription],
        columnExpiry: row[columnExpiry]
      };
      LicenseRecord license = LicenseRecord.fromMap(map);
      licenses.add(license);
    }
    return licenses;
  }
}
