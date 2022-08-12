/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'keystore_model.dart';

class KeystoreRepository {
  static const _keyPrefix = 'com.mytiki.wallet.keystore.';
  final FlutterSecureStorage _secureStorage;

  KeystoreRepository(this._secureStorage);

  Future<void> save(KeystoreModel model) => _secureStorage.write(
      key: _keyPrefix + model.address!, value: jsonEncode(model.toJson()));

  Future<KeystoreModel?> get(String address) async {
    String? raw = await _secureStorage.read(key: _keyPrefix + address);
    return raw != null ? KeystoreModel.fromJson(jsonDecode(raw)) : null;
  }

  Future<void> delete(String address) =>
      _secureStorage.delete(key: _keyPrefix + address);

  Future<bool> exists(String address) async {
    String? raw = await _secureStorage.read(key: _keyPrefix + address);
    return raw == null ? false : true;
  }
}
