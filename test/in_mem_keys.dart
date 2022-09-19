/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */
/// {@category Utils}
import '../lib/node/keys/keys_interface.dart';

/// A ephemeral key-value storage.
class InMemoryKeys extends KeysInterface {
  Map<String, String> storage = {};

  @override
  Future<String?> read({required String key}) async => storage[key];

  @override
  Future<void> write({required String key, required String value}) async =>
      storage[key] = value;
}
