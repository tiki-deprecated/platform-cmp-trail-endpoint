// /*
//  * Copyright (c) TIKI Inc.
//  * MIT license. See LICENSE file in root directory.
//  */

import 'dart:convert';

import 'keys_model.dart';
import 'keys_secure_storage_interface.dart';

class KeysRepository {
  static const _keyPrefix = 'com.mytiki.sdk.';
  late final KeysSecureStorageInterface _secureStorage;

  KeysRepository(this._secureStorage);

  Future<void> save(KeysModel model) => _secureStorage.write(
      key: _keyPrefix + base64Url.encode(model.address),
      value: jsonEncode(model.toMap()));

  Future<KeysModel?> get(String address) async {
    String? raw = await _secureStorage.read(key: _keyPrefix + address);
    return raw != null ? KeysModel.fromMap(jsonDecode(raw)) : null;
  }

  Future<void> delete(String address) =>
      _secureStorage.delete(key: _keyPrefix + address);

  Future<bool> exists(String address) async {
    String? raw = await _secureStorage.read(key: _keyPrefix + address);
    return raw == null ? false : true;
  }
}
