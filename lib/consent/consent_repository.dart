// ignore_for_file: unused_field

/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */
/// {@category SDK}
import 'package:sqlite3/sqlite3.dart';
import '../ownership/ownership_model.dart';
import 'cosent_model.dart';

/// The repository for [ConsentModel] persistence.
class ConsentRepository {
  final Database _db;

  static const table = 'consent';

  static const columnAssetRef = 'assetRef';
  static const columnDestination = 'destination';
  static const columnAbout = 'about';
  static const columnReward = 'reward';
  static const columnTransactionId = 'transaction_id';

  /// Builds a [ConsentRepository] that will use [_db] for persistence.
  ///
  /// It calls [createTable] to make sure the table exists.
  ConsentRepository(this._db) {
    _createTable();
  }

  /// Creates the [ConsentRepository.table] if it does not exist.
  void _createTable() => _db.execute('''
    CREATE TABLE IF NOT EXISTS $table (
     $columnAssetRef TEXT,
     $columnDestination TEXT,
     $columnAbout TEXT,
     $columnReward TEXT
     $columnTransactionId TEXT,
      );
    ''');

  /// Persists [consent] in [_db].
  void save(ConsentModel consent) {
    _db.execute('''
    INSERT INTO $table 
    VALUES ( ?, ?, ?, ?, ?);
    ''',
        [consent.assetRef, 
        consent.destination.toString(), 
        consent.about, 
        consent.reward, 
        consent.transactionId]);
  }

  /// Gets the [OwnerShipModel] for [source] and [origin] in database.
  List<ConsentModel> getByOwnership(OwnershipModel ownership) {
    String where = "WHERE $columnAssetRef = ?";
    List<ConsentModel> consents =
        _select(whereStmt: where, params: [ownership.transactionId]);
    return consents;
  }

  List<ConsentModel> _select({String? whereStmt, List params = const []}) {
    ResultSet results = _db.select('''
      SELECT * FROM $table
      ${whereStmt ?? ''};
      ''', params);
    List<ConsentModel> consents = [];
    for (final Row row in results) {
      Map<String, dynamic> map = {
        columnAssetRef: row[columnAssetRef],
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
