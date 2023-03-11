/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:typed_data';

import 'package:sqlite3/common.dart';

import '../../utils/bytes.dart';
import 'xchain_model.dart';

class XChainRepository {
  static const table = 'xchain';

  static const columnSrc = 'src';
  static const columnAddress = 'address';
  static const columnBlockId = 'block_id';
  static const columnFetchedOn = 'fetched_on';

  final CommonDatabase _db;

  XChainRepository(this._db) {
    _createTable();
  }

  void _createTable() => _db.execute('''
    CREATE TABLE IF NOT EXISTS $table (
      $columnSrc TEXT NOT NULL UNIQUE,
      $columnAddress BLOB,
      $columnBlockId BLOB,
      $columnFetchedOn INTEGER
      );
    ''');

  XChainModel? getBySrc(String src) {
    List<XChainModel> xcs =
        _select(whereStmt: "WHERE $columnSrc = '${src.toLowerCase()}'");
    return xcs.isNotEmpty ? xcs.first : null;
  }

  List<XChainModel> getAllByAddress(Uint8List address) => _select(
      whereStmt: "WHERE $columnAddress = x'${Bytes.hexEncode(address)}'");

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
