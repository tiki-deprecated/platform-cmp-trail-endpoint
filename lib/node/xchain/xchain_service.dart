/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */
library xchain;

export 'xchain_repository.dart';
export 'xchain_model.dart';

import 'dart:typed_data';

import 'package:sqlite3/sqlite3.dart';

import '../../utils/utils.dart';
import 'xchain_repository.dart';
import 'xchain_model.dart';

/// {@category Node}
/// The service to handle [XchainModel] references and updates.
class XchainService {
  final XchainRepository _repository;

  XchainService(Database db) : _repository = XchainRepository(db);

  /// Adds a new Xchain by [publicKey].
  ///
  /// The service will derive the [XchainModel.address].
  /// If the address already exists, it will not be added.
  /// method will be called.
  XchainModel add(CryptoRSAPublicKey publicKey) {
    XchainModel xchainModel = XchainModel(publicKey);
    _repository.save(xchainModel);
    return xchainModel;
  }

  /// Updates the [XchainModel.lastBlock].
  void update(String address, Uint8List lastBlock) =>
      _repository.update(address, lastBlock);

  XchainModel? get(String address) => _repository.get(address);
}
