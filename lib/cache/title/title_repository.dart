// ignore_for_file: unused_field

/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:typed_data';

import 'package:sqlite3/sqlite3.dart';

import '../../node/transaction/transaction_repository.dart';
import '../../utils/bytes.dart';
import 'title_record.dart';

/// The repository for [TitleRecord] persistence.
class TitleRepository {
  final Database _db;
  static const table = 'title_record';
  static const String columnPtr = 'ptr';
  static const String columnOrigin = 'origin';
  static const String columnTransactionId = 'transaction_id';
  static const String columnDescription = 'description';
  static const String columnTags = 'tags';

  /// Builds a [TitleRepository] that will use [_db] for persistence.
  ///
  /// It calls [_createTable] to make sure the table exists.
  TitleRepository(this._db) {
    _createTable();
  }

  /// Creates the [TitleRepository.table] if it does not exist.
  void _createTable() => _db.execute('''
    CREATE TABLE IF NOT EXISTS $table (
      $columnTransactionId BLOB PRIMARY KEY,
      $columnPtr TEXT,
      $columnOrigin TEXT,
      $columnDescription TEXT,
      $columnTags TEXT,
      CONSTRAINT fk_transaction_id
        FOREIGN KEY ($columnTransactionId)
        REFERENCES ${TransactionRepository.table}(${TransactionRepository.columnId})
      );
    ''');

  /// Persists [title] in [_db].
  void save(TitleRecord title) {
    Map map = title.toMap();
    _db.execute('''
    INSERT INTO $table 
    VALUES ( ?, ?, ?, ?, ?);
    ''', [
      map[columnTransactionId],
      map[columnPtr],
      map[columnOrigin],
      map[columnDescription],
      jsonEncode(map[columnTags])
    ]);
  }

  /// Gets all [TitleRecord] stored in local database.
  List<TitleRecord> getAll() => _select();

  TitleRecord? getById(Uint8List id) {
    List<TitleRecord> titles = _select(
        whereStmt: "WHERE $columnTransactionId = x'${Bytes.hexEncode(id)}'");
    return titles.isNotEmpty ? titles.first : null;
  }

  /// Gets the [TitleRecord] for [ptr] and [origin] in database.
  TitleRecord? getByPtr(String ptr, String origin) {
    List params = [ptr, origin];
    String where = "WHERE $columnPtr = ? AND $columnOrigin = ?";
    List<TitleRecord> titles = _select(whereStmt: where, params: params);
    return titles.isNotEmpty ? titles.first : null;
  }

  List<TitleRecord> _select({String? whereStmt, List params = const []}) {
    ResultSet results = _db.select('''
      SELECT * FROM $table
      ${whereStmt ?? ''};
      ''', params);
    List<TitleRecord> titles = [];
    for (final Row row in results) {
      Map<String, dynamic> map = {
        columnTransactionId: row[columnTransactionId],
        columnPtr: row[columnPtr],
        columnOrigin: row[columnOrigin],
        columnDescription: row[columnDescription],
        columnTags: jsonDecode(row[columnTags])
            .map<String>((e) => e.toString())
            .toList()
      };
      TitleRecord record = TitleRecord.fromMap(map);
      titles.add(record);
    }
    return titles;
  }
}
