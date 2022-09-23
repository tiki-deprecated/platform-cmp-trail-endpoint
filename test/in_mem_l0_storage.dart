/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:typed_data';

import 'package:tiki_sdk_dart/node/l0_storage.dart';

class InMemL0Storage implements L0Storage {
  Map<String, Uint8List> storage = {};

  @override
  Future<Uint8List> read(String path) async {
    Uint8List value = storage[path]!;
    return value;
  }

  @override
  Future<void> write(String path, Uint8List obj) async {
    storage[path] = obj;
  }
}
