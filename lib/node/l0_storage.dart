/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */
import 'dart:typed_data';

/// The service to use Wasabi object storage.
abstract class L0Storage {
  Future<Uint8List?> read(String path);

  Future<void> write(String path, Uint8List obj);
}
