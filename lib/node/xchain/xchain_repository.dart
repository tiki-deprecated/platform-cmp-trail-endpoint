/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */
/// {@category Node}
import 'dart:typed_data';

import 'package:sqlite3/sqlite3.dart';

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
    throw UnimplementedError();
  }

  /// Persists [xchain] in [_db].
  void save(XchainModel xchain) {
    throw UnimplementedError();
  }

  /// Updates the persisted [XchainModel.lastBlock].
  void update(String address, Uint8List lastBlock) {
    throw UnimplementedError();
  }

  List<XchainModel> _select({String? whereStmt}) {
    throw UnimplementedError();
  }
}
