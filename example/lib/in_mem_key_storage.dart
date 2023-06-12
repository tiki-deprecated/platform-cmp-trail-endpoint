/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:tiki_trail/tiki_sdk.dart';
import 'package:tiki_trail/utils/rsa/rsa.dart';

class InMemKeyStorage extends KeyStorage {
  Map<String, String> storage = {};

  @override
  Future<String> generate() async {
    RsaKeyPair rsaKeyPair = await Rsa.generateAsync();
    return rsaKeyPair.privateKey.encode();
  }

  @override
  Future<String?> read(String key) async => storage[key];

  @override
  Future<void> write(String key, String value) async => storage[key] = value;
}
