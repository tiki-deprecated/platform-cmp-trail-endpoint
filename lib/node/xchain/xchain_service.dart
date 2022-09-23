/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */
library xchain;

export 'xchain_repository.dart';
export 'xchain_model.dart';

import 'dart:convert';
import 'dart:typed_data';

import 'package:sqlite3/sqlite3.dart';

import '../../utils/utils.dart';
import '../backup/backup_storage_interface.dart';
import '../node_service.dart';

/// {@category Node}
/// The service to handle [XchainModel] references and updates.
class XchainService {
  final XchainRepository _repository;

  final BackupStorageInterface _backupStorage;

  XchainService(Database db, this._backupStorage)
      : _repository = XchainRepository(db);

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
  void update(Uint8List address, Uint8List lastBlock) =>
      _repository.update(address, lastBlock);

  XchainModel? get(Uint8List address) => _repository.get(address);

  Future<XchainModel> load(Uint8List address) async {
    XchainModel? xchain = _repository.get(address);
    if (xchain == null) {
      Uint8List bytesPublicKey =
          await _backupStorage.read('${base64Url.encode(address)}/public.key');
      CryptoRSAPublicKey publicKey =
          CryptoRSAPublicKey.decode(base64Encode(bytesPublicKey));
      xchain = add(publicKey);
    }
    return xchain;
  }
}
