/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:typed_data';

import 'package:pointycastle/export.dart';
import 'package:uuid/uuid.dart';

import '../../utils/rsa/rsa.dart';
import 'key_model.dart';
import 'key_repository.dart';
import 'key_storage.dart';

/// The service that handles keys creation and persistance.
class KeyService {
  final KeyRepository _repository;

  KeyService(KeyStorage keyStorage) : _repository = KeyRepository(keyStorage);

  /// Create a new [RsaKeyPair] and save its public key in object storage.
  Future<KeyModel> create({String? id}) async {
    RsaKeyPair rsaKeyPair = await Rsa.generateAsync();
    Uint8List address = Digest("SHA3-256").process(rsaKeyPair.publicKey.bytes);
    KeyModel keys = KeyModel(
      id ?? const Uuid().v4(),
      address,
      rsaKeyPair.privateKey,
    );
    _repository.save(keys);
    return keys;
  }

  /// Gets a persisted [KeyModel].
  Future<KeyModel?> get(String id) => _repository.get(id);
}
