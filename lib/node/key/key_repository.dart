/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */
/// {@category Node}
import 'dart:convert';

import 'key_interface.dart';
import 'key_model.dart';

/// The repository that performs read and write operations in the keys storage.
class KeyRepository {
  static const _keyPrefix = 'com.mytiki.sdk.';
  late final KeyInterface _keyInterface;

  KeyRepository(this._keyInterface);

  Future<void> save(KeyModel model) => _keyInterface.write(
      key: _keyPrefix + base64.encode(model.address), value: model.toJson());

  Future<KeyModel?> get(String address) async {
    String? raw = await _keyInterface.read(key: _keyPrefix + address);
    return raw != null ? KeyModel.fromJson(raw) : null;
  }
}
