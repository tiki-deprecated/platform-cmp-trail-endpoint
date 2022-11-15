/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */
/// {@category Node}
import 'dart:convert';

import 'key_model.dart';
import 'key_storage.dart';

/// The repository that performs read and write operations in the keys storage.
class KeyRepository {
  static const _keyPrefix = 'com.mytiki.sdk.';
  late final KeyStorage _keyStorage;

  KeyRepository(this._keyStorage);

  Future<void> save(KeyModel model) => _keyStorage.write(
      key: _keyPrefix + base64Url.encode(model.address), value: model.toJson());

  Future<KeyModel?> get(String address) async {
    String? raw = await _keyStorage.read(key: _keyPrefix + address);
    return raw != null ? KeyModel.fromJson(raw) : null;
  }
}
