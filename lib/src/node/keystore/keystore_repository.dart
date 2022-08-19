// /*
//  * Copyright (c) TIKI Inc.
//  * MIT license. See LICENSE file in root directory.
//  */

import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'keystore_model.dart';

class KeystoreRepository {
  static const _keyPrefix = 'com.tiki.sdk.';
  late final FlutterSecureStorage _secureStorage;

  KeystoreRepository({secureStorage}) {
    _secureStorage = secureStorage ?? FlutterSecureStorage();
  }

  Future<void> save(KeystoreModel model) => _secureStorage.write(
      key: _keyPrefix + model.address, value: jsonEncode(model.toMap()));

  Future<KeystoreModel?> get(String address) async {
    String? raw = await _secureStorage.read(key: _keyPrefix + address);
    return raw != null ? KeystoreModel.fromMap(jsonDecode(raw)) : null;
  }

  Future<void> delete(String address) =>
      _secureStorage.delete(key: _keyPrefix + address);

  Future<bool> exists(String address) async {
    String? raw = await _secureStorage.read(key: _keyPrefix + address);
    return raw == null ? false : true;
  }
}
