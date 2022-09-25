/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */
/// {@category Node}
/// Handles cross chain references.
library xchain;

import 'dart:convert';
import 'dart:typed_data';

import 'package:sqlite3/sqlite3.dart';

import '../../utils/utils.dart';
import '../l0_storage.dart';
import 'xchain_model.dart';
import 'xchain_repository.dart';

export 'xchain_model.dart';
export 'xchain_repository.dart';

/// The service to handle [XchainModel] references and updates.
class XchainService {
  final XchainRepository _repository;
  final L0Storage _l0storage;

  XchainService(Database db, this._l0storage)
      : _repository = XchainRepository(db);

  /// Adds a new Xchain by [publicKey].
  ///
  /// The service will derive the [XchainModel.address].
  /// If the address already exists, it will not be added.
  /// method will be called.
  XchainModel add(RsaPublicKey publicKey) {
    XchainModel xchainModel = XchainModel(publicKey);
    _repository.save(xchainModel);
    return xchainModel;
  }

  /// Updates the [XchainModel.lastBlock].
  void update(Uint8List address, Uint8List lastBlock) =>
      _repository.update(address, lastBlock);

  /// Gets a xchain from local database.
  XchainModel? get(Uint8List address) => _repository.get(address);

  /// Loads a xchain from remote backup storage.
  Future<XchainModel> load(Uint8List address) async {
    XchainModel? xchain = _repository.get(address);
    if (xchain == null) {
      Uint8List? bytesPublicKey =
          await _l0storage.read('${base64Url.encode(address)}/public.key');
      RsaPublicKey publicKey =
          RsaPublicKey.decode(base64Encode(bytesPublicKey!));
      xchain = add(publicKey);
    }
    return xchain;
  }
}
