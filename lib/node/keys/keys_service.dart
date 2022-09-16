/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */
/// {@category Node}
import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';

import '../../utils/rsa/rsa.dart';
import 'keys_interface.dart';
import 'keys_model.dart';
import 'keys_repository.dart';

class KeysService {
  final KeysRepository _repository;

  KeysService(KeysInterface secureStorageStrategy)
      : _repository = KeysRepository(secureStorageStrategy);

  /// Create a new [RsaKeyPair] and save its public key in object storage.
  Future<KeysModel> create() async {
    RsaKeyPair rsaKeyPair = await generateAsync();
    Uint8List address = Digest("SHA3-256")
        .process(base64.decode(rsaKeyPair.publicKey.encode()));
    KeysModel keys = KeysModel(
      address,
      rsaKeyPair.privateKey,
    );
    _repository.save(keys);
    return keys;
  }

  /// Gets a persisted [KeysModel].
  Future<KeysModel?> get(String address) async =>
      await _repository.get(address);
}
