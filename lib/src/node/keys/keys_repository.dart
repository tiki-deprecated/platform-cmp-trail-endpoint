// /*
//  * Copyright (c) TIKI Inc.
//  * MIT license. See LICENSE file in root directory.
//  */

import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'keys_model.dart';

class KeysRepository {
  static const _keyPrefix = 'com.tiki.sdk.';
  late final FlutterSecureStorage _secureStorage;

  KeysRepository({secureStorage}) {
    _secureStorage = secureStorage ?? FlutterSecureStorage();
  }

  Future<void> save(KeysModel model) => _secureStorage.write(
      key: _keyPrefix + model.address, value: jsonEncode(model.toMap()));

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
