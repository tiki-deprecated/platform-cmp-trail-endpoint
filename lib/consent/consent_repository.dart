/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */
import 'dart:typed_data';

import 'package:sqlite3/sqlite3.dart';

import '../node/node_service.dart';
import '../ownership/ownership_repository.dart';
import '../utils/bytes.dart';
import 'consent_model.dart';

/// The repository for [ConsentModel] persistence.
class ConsentRepository {
  final Database _db;

  /// The table that will persist [ConsentModel]
  static const table = 'consent';

  /// The table column for [ConsentModel.ownershipId]
  static const columnOwnershipId = 'ownershipId';

  /// The table column for [ConsentModel.destination]
  static const columnDestination = 'destination';

  /// The table column for [ConsentModel.about]
  static const columnAbout = 'about';

  /// The table column for [ConsentModel.reward]
  static const columnReward = 'reward';

  /// The table column for [ConsentModel.transactionId]
  static const columnTransactionId = 'transaction_id';

  /// The tabl column for [ConsentModel.expiry]
  static const columnExpiry = 'expiry';

  /// Builds a [ConsentRepository] that will use [_db] for persistence.
  ///
  /// It calls [createTable] to make sure the table exists.
  ConsentRepository(this._db) {
    _createTable();
  }

  /// Creates the [ConsentRepository.table] if it does not exist.
  void _createTable() => _db.execute('''
    CREATE TABLE IF NOT EXISTS $table (
     $columnOwnershipId TEXT,
     $columnDestination TEXT,
     $columnAbout TEXT,
     $columnReward TEXT,
     $columnTransactionId TEXT,
     FOREIGN KEY($columnOwnershipId) 
      REFERENCES ${OwnershipRepository.table}(${OwnershipRepository.columnTransactionId}),
     FOREIGN KEY($columnTransactionId) 
      REFERENCES ${TransactionRepository.table}(${TransactionRepository.columnId})
      );
    ''');

  /// Persists [consent] in [_db].
  void save(ConsentModel consent) {
    _db.execute('''
    INSERT INTO $table 
    VALUES ( ?, ?, ?, ?, ?);
    ''', [
      consent.ownershipId,
      consent.destination.toString(),
      consent.about,
      consent.reward,
      consent.transactionId
    ]);
  }

  /// Gets the [OwnerShipModel] for [source] and [origin] in database.
  ConsentModel? getByOwnershipId(Uint8List ownershipId) {
    String where = '''WHERE $columnOwnershipId = 
      x'${Bytes.hexEncode(ownershipId)}' ORDER BY $table.oid DESC LIMIT 1''';
    List<ConsentModel> consents = _select(whereStmt: where, params: []);
    return consents.isNotEmpty ? consents.first : null;
  }

  List<ConsentModel> _select({String? whereStmt, List params = const []}) {
    ResultSet results = _db.select('''
      SELECT * FROM $table
      ${whereStmt ?? ''};
      ''', params);
    List<ConsentModel> consents = [];
    for (final Row row in results) {
      Map<String, dynamic> map = {
        columnOwnershipId: row[columnOwnershipId],
        columnDestination: row[columnDestination],
        columnAbout: row[columnAbout],
        columnReward: row[columnReward],
      };
      ConsentModel consentModel = ConsentModel.fromMap(map);
      consents.add(consentModel);
    }
    return consents;
  }
}
