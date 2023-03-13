/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:typed_data';

import 'package:sqlite3/common.dart';

import '../../utils/bytes.dart';
import 'xchain_model.dart';

/// The repository for [XChainModel] persistance in [CommonDatabase].
class XChainRepository {
  /// The [XChainModel] table name in [db].
  static const table = 'xchain';

  /// The [XChainModel.src] column.
  static const columnSrc = 'src';

  /// The [XChainModel.address] column.
  static const columnAddress = 'address';

  /// The [XChainModel.blockId] column.
  static const columnBlockId = 'block_id';

  /// The [XChainModel.fetchedOn] column.
  static const columnFetchedOn = 'fetched_on';

  /// The [CommonDatabase] used to persist [BlockModel].
  final CommonDatabase _db;

  /// Builds a [XChainRepository] that will use [db] for persistence.
  ///
  /// It calls [createTable] to make sure the table exists.
  XChainRepository(this._db) {
    _createTable();
  }

  /// Creates the [XChainRepository.table] if it does not exist.
  void _createTable() => _db.execute('''
    CREATE TABLE IF NOT EXISTS $table (
      $columnSrc TEXT NOT NULL UNIQUE,
      $columnAddress BLOB,
      $columnBlockId BLOB,
      $columnFetchedOn INTEGER
      );
    ''');

  /// Returns all [XChainModel]s for the [address]
  List<XChainModel> getAllByAddress(Uint8List address) => _select(
      whereStmt: "WHERE $columnAddress = x'${Bytes.hexEncode(address)}'");

  /// Save a [xc] in the [db]
  void save(XChainModel xc) {
    Map map = xc.toMap();
    _db.execute('''
    INSERT INTO $table 
    VALUES ( ?, ?, ?, ? );
    ''', [
      map[columnSrc],
      map[columnAddress],
      map[columnBlockId],
      map[columnFetchedOn]
    ]);
  }

  /// Select using a [whereStmt] and map results to [XChainModel]s
  List<XChainModel> _select({String? whereStmt}) {
    ResultSet results = _db.select('''
      SELECT 
        $table.$columnSrc as '$columnSrc',
        $table.$columnAddress as '$columnAddress',
        $table.$columnBlockId as '$columnBlockId',
        $table.$columnFetchedOn as '$columnFetchedOn'
      FROM $table
      ${whereStmt ?? ''};
      ''');
    List<XChainModel> xcs = [];
    for (final Row row in results) {
      Map<String, dynamic> xcMap = {
        columnSrc: row[columnSrc],
        columnAddress: row[columnAddress],
        columnBlockId: row[columnBlockId],
        columnFetchedOn: row[columnFetchedOn]
      };
      XChainModel xc = XChainModel.fromMap(xcMap);
      xcs.add(xc);
    }
    return xcs;
  }
}
