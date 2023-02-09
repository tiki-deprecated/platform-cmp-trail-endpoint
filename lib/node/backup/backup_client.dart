/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

library l0_storage;

import 'dart:typed_data';

abstract class BackupClient {
  Future<void> write(String key, Uint8List value);
  Future<Uint8List?> read(String key);
}
