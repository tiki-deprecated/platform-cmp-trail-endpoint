/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */
/// {@category Node}
import 'dart:typed_data';

import 'package:sqlite3/sqlite3.dart';

import '../../utils/utils.dart';
import 'xchain_model.dart';

/// The cross chain repository for [XchainModel] database persistance.
class XchainRepository {
  /// The [XchainModel] table name in [_db].
  static const table = 'xchain';

  /// The base64Url representation of the chain address.
  static const columnAddress = 'address';

  /// The chain public key.
  static const columnPublicKey = 'public_key';

  /// The bae64Url representation of the [BlockModel.id] for the last validated block.
  static const columnLastBlock = 'last_block';

  final Database _db;

  /// Builds a [XchainRepository] that will use [_db] for persistence.
  ///
  /// It calls [createTable] to make sure the table exists.
  XchainRepository(this._db) {
    createTable();
  }

  /// Creates the [XchainRepository.table] if it does not exist.
  void createTable() async {
    _db.execute('''
      CREATE TABLE IF NOT EXISTS $table (
        $columnAddress BLOB PRIMARY KEY,
        $columnPublicKey TEXT,
        $columnLastBlock BLOB
      );
    ''');
  }

  /// Persists [xchain] in [_db].
  void save(XchainModel xchain) {
    _db.execute('INSERT INTO $table VALUES ( ?, ?, ? );',
        [xchain.address, xchain.publicKey.encode(), xchain.lastBlock]);
  }

  /// Updates the persisted [XchainModel.lastBlock].
  void update(Uint8List address, Uint8List lastBlock) {
    _db.execute(
        'UPDATE $table SET $columnLastBlock = ? WHERE $columnAddress = ?',
        [lastBlock, address]);
  }

  /// Gets a xchain by its address.
  XchainModel? get(Uint8List address) {
    List<XchainModel> results =
        _select(whereStmt: 'WHERE $columnAddress = "$address"');
    return results.isNotEmpty ? results.single : null;
  }

  List<XchainModel> _select({String? whereStmt}) {
    ResultSet results = _db.select('''
        SELECT * FROM $table
        ${whereStmt ?? 'WHERE 1=1'}
        ''');
    List<XchainModel> backups = [];
    for (final Row row in results) {
      Map<String, dynamic> xchainMap = {
        columnAddress: row[columnAddress],
        columnPublicKey: RsaPublicKey.decode(row[columnPublicKey]),
        columnLastBlock: row[columnLastBlock],
      };
      XchainModel xchain = XchainModel.fromMap(xchainMap);
      backups.add(xchain);
    }
    return backups;
  }
}
