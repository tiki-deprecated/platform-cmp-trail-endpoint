// ignore_for_file: unused_field

/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */
/// {@category SDK}
import 'dart:convert';
import 'dart:typed_data';

import 'package:sqlite3/sqlite3.dart';
import '../node/transaction/transaction_service.dart';
import '../tiki_sdk.dart';
import '../utils/bytes.dart';
import 'ownership_model.dart';

/// The repository for [OwnershipModel] persistence.
class OwnershipRepository {
  final Database _db;
  static const table = 'ownership';

  static const String columnSource = 'source';

  static const String columnType = 'type';

  static const String columnOrigin = 'origin';

  static const String columnTransactionId = 'transaction_id';

  static const String columnAbout = 'about';

  static const String columnContains = 'contains';

  /// Builds a [OwnershipRepository] that will use [_db] for persistence.
  ///
  /// It calls [createTable] to make sure the table exists.
  OwnershipRepository(this._db) {
    _createTable();
  }

  /// Creates the [OwnershipRepository.table] if it does not exist.
  void _createTable() => _db.execute('''
    CREATE TABLE IF NOT EXISTS $table (
      $columnTransactionId BLOB PRIMARY KEY,
      $columnSource TEXT,
      $columnType TEXT,
      $columnOrigin TEXT,
      $columnAbout TEXT,
      $columnContains TEXT,
      CONSTRAINT fk_transaction_id
        FOREIGN KEY ($columnTransactionId)
        REFERENCES ${TransactionRepository.table}(${TransactionRepository.columnId})
      );
    ''');

  /// Persists [ownership] in [_db].
  void save(OwnershipModel ownership) {
    _db.execute('''
    INSERT INTO $table 
    VALUES ( ?, ?, ?, ?, ?, ?);
    ''', [
      ownership.transactionId,
      ownership.source,
      ownership.type.val,
      ownership.origin,
      ownership.about,
      jsonEncode(ownership.contains)
    ]);
  }

  /// Gets all [OwnerShipModel] stored in local database.
  List<OwnershipModel> getAll() => _select();

  OwnershipModel? getById(Uint8List id) {
    List<OwnershipModel> ownerships = _select(
        whereStmt: "WHERE $columnTransactionId = x'${Bytes.hexEncode(id)}'");
    return ownerships.isNotEmpty ? ownerships.first : null;
  }

  /// Gets the [OwnerShipModel] for [source] and [origin] in database.
  OwnershipModel? getBySource(String source, String origin) {
    List params = [source, origin];
    String where = "WHERE $columnSource = ? AND $columnOrigin = ?";
    List<OwnershipModel> ownerships = _select(whereStmt: where, params: params);
    return ownerships.isNotEmpty ? ownerships.first : null;
  }

  List<OwnershipModel> _select({String? whereStmt, List params = const []}) {
    ResultSet results = _db.select('''
      SELECT * FROM $table
      ${whereStmt ?? ''};
      ''', params);
    List<OwnershipModel> ownerships = [];
    for (final Row row in results) {
      Map<String, dynamic> map = {
        columnTransactionId: row[columnTransactionId],
        columnSource: row[columnSource],
        columnType: TikiSdkDataTypeEnum.fromValue(row[columnType]),
        columnOrigin: row[columnOrigin],
        columnAbout: row[columnAbout],
        columnContains: jsonDecode(row[columnContains])
            .map<String>((e) => e.toString())
            .toList()
      };
      OwnershipModel ownershipModel = OwnershipModel.fromMap(map);
      ownerships.add(ownershipModel);
    }
    return ownerships;
  }
}
