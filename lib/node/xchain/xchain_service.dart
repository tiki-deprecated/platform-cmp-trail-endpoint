/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */
library xchain;

export 'xchain_repository.dart';
export 'xchain_model.dart';

import 'dart:typed_data';

import 'package:sqlite3/sqlite3.dart';

import 'xchain_repository.dart';
import 'xchain_model.dart';

/// {@category Node}
/// The service to handle [XchainModel] references and updates.
class XchainService {
  XchainRepository _repository;

  XchainService(Database db) : _repository = XchainRepository(db);

  /// Adds a new Xchain by [publicKey] base64 representation.
  ///
  /// The service will derive the [XchainModel.address].
  /// If the address already exists, it will not be added.
  /// method will be called.
  XchainModel add(String publicKey) {
    throw UnimplementedError();
  }

  /// Updates the [XchainModel.lastBlock].
  Future<void> update(String address, Uint8List lastBlock) {
    throw UnimplementedError();
  }

  XchainModel? get(String address) {}
}
