/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */
/// {@category Node}
abstract class KeysInterface {
  Future<void> write({required String key, required String value});

  Future<String?> read({required String key});
}
