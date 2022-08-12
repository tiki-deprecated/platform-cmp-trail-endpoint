/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'keystore_model.dart';
import 'keystore_repository.dart';

class KeystoreService {
  final KeystoreRepository _repository;

  KeystoreService({FlutterSecureStorage? secureStorage})
      : _repository =
            KeystoreRepository(secureStorage ?? const FlutterSecureStorage());

  Future<void> add(KeystoreModel model) async {
    if (model.address == null) {
      throw ArgumentError("model.address cannot be null");
    }

    bool exists = await _repository.exists(model.address!);
    if (exists) {
      throw StateError("model already exists. try removing it first.");
    }

    _repository.save(model);
  }

  Future<KeystoreModel?> get(String address) async => await _repository.get(address);

  Future<void> remove(String address) => _repository.delete(address);
}
