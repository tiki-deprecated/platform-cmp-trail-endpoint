/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:typed_data';

/// Interface for writing to a Backup Service
abstract class BackupClient {
  /// Write a binary object ([value]) to the Backup Service with a [key].
  Future<void> write(String key, Uint8List value);
}
