/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import '../../utils/rsa/rsa_private_key.dart';
import 'key_model.dart';
import 'key_storage.dart';

/// The repository that performs read and write operations in the keys storage.
class KeyRepository {
  static const _keyPrefix = 'com.mytiki.sdk';
  late final KeyStorage _keyStorage;

  KeyRepository(this._keyStorage);

  Future<RsaPrivateKey> generate() async {
    String encoded = await _keyStorage.generate();
    return RsaPrivateKey.decode(encoded);
  }

  Future<void> save(KeyModel model) =>
      _keyStorage.write('$_keyPrefix.${model.id}', model.toJson());

  Future<KeyModel?> get(String id) async {
    String? raw = await _keyStorage.read('$_keyPrefix.$id');
    return raw != null ? KeyModel.fromJson(id, raw) : null;
  }
}
