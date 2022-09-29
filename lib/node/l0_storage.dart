/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */
import 'dart:typed_data';

/// The interface to implement L0 backup object storage.
abstract class L0Storage {
  Future<Uint8List?> read(String path);

  Future<void> write(String path, Uint8List obj);

  Future<Map<String, Uint8List>> getAll(String address);
}
