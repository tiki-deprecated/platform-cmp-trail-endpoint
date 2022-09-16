/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */
/// {@category Node}
import 'dart:convert';

import 'keys_interface.dart';
import 'keys_model.dart';

/// The repository that performs read and write operations in the keys storage.
class KeysRepository {
  static const _keyPrefix = 'com.mytiki.sdk.';
  late final KeysInterface _keysInterface;

  KeysRepository(this._keysInterface);

  Future<void> save(KeysModel model) => _keysInterface.write(
      key: _keyPrefix + base64.encode(model.address), value: model.toJson());

  Future<KeysModel?> get(String address) async {
    String? raw = await _keysInterface.read(key: _keyPrefix + address);
    return raw != null ? KeysModel.fromJson(raw) : null;
  }
}
