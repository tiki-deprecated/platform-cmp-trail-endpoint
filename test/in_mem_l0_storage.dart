/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:typed_data';

import 'package:tiki_sdk_dart/node/backup/backup_client.dart';

class InMemL0Storage implements BackupClient {
  Map<String, Map<String, Uint8List>> storage = {};

  @override
  Future<void> write(String key, Uint8List value) async {
    List<String> keys = key.split('/');
    String address = keys[0];
    String id = keys[1];
    if (storage[address] == null) storage[address] = {};
    storage[address]![id] = value;
  }

  @override
  Future<Uint8List?> read(String key) async {
    List<String> keys = key.split('/');
    String address = keys[0];
    String id = keys[1];
    return storage[address]?[id];
  }
}
