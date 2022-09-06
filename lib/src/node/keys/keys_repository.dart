// /*
//  * Copyright (c) TIKI Inc.
//  * MIT license. See LICENSE file in root directory.
//  */

import 'dart:convert';

import '../secure_storage_sttgy_if.dart';
import 'keys_model.dart';

class KeysRepository {
  static const _keyPrefix = 'com.mytiki.sdk.';
  late final SecureStorageStrategyIf _secureStorage;

  KeysRepository(this._secureStorage);

  Future<void> save(KeysModel model) => _secureStorage.write(
      key: _keyPrefix + base64.encode(model.address), 
      value: model.toJson());

  Future<KeysModel?> get(String address) async {
    String? raw = await _secureStorage.read(key: _keyPrefix + address);
    return raw != null ? KeysModel.fromJson(raw) : null;
  }

  Future<void> delete(String address) =>
      _secureStorage.delete(key: _keyPrefix + address);

  Future<bool> exists(String address) async {
    String? raw = await _secureStorage.read(key: _keyPrefix + address);
    return raw == null ? false : true;
  }
}
