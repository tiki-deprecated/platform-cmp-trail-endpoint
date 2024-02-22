/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

// ignore_for_file: unused_field

import 'dart:convert';
import 'dart:typed_data';

import 'package:sqlite3/common.dart';

import '../../node/transaction/transaction_repository.dart';
import '../../utils/bytes.dart';
import 'title_model.dart';

/// The repository for [TitleModel] persistence.
class TitleRepository {
  final CommonDatabase _db;
  static const table = 'title_record';
  static const String columnPtr = 'ptr';
  static const String columnOrigin = 'origin';
  static const String columnTransactionId = 'transaction_id';
  static const String columnDescription = 'description';
  static const String columnTags = 'tags';
  static const timestamp = 'timestamp';

  /// Builds a [TitleRepository] that will use [_db] for persistence.
  ///
  /// Calls [_createTable] to ensure the table exists.
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
  void save(TitleModel title) {
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

  /// Gets all [TitleModel] stored in the local database.
  List<TitleModel> getAll() => _select();

  /// Gets the [TitleModel] by transaction_[id] from the database.
  TitleModel? getById(Uint8List id) {
    List<TitleModel> titles = _select(
        whereStmt: "WHERE $columnTransactionId = x'${Bytes.hexEncode(id)}'");
    return titles.isNotEmpty ? titles.first : null;
  }

  /// Gets the [TitleModel] for [ptr] and [origin] from the database.
  TitleModel? getByPtr(String ptr, String origin) {
    List params = [ptr, origin];
    String where = "WHERE $columnPtr = ? AND $columnOrigin = ?";
    List<TitleModel> titles = _select(whereStmt: where, params: params);
    return titles.isNotEmpty ? titles.first : null;
  }

  List<TitleModel> _select({String? whereStmt, List params = const []}) {
    ResultSet results = _db.select('''
      SELECT * FROM $table
      LEFT JOIN ${TransactionRepository.table} 
      ON $table.$columnTransactionId = ${TransactionRepository.table}.${TransactionRepository.columnId} 
      ${whereStmt ?? ''};
      ''', params);
    List<TitleModel> titles = [];
    for (final Row row in results) {
      Map<String, dynamic> map = {
        columnTransactionId: row[columnTransactionId],
        columnPtr: row[columnPtr],
        columnOrigin: row[columnOrigin],
        columnDescription: row[columnDescription],
        columnTags: jsonDecode(row[columnTags])
            .map<String>((e) => e.toString())
            .toList(),
        timestamp: row[timestamp]
      };
      TitleModel record = TitleModel.fromMap(map);
      titles.add(record);
    }
    return titles;
  }
}
