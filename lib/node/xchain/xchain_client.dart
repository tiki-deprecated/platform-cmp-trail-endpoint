/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:typed_data';

/// Interface for reading from multi-address storage
abstract class XChainClient {
  /// Returns the binary object for the [key].
  Future<Uint8List?> read(String key);

  /// Returns a list of keys underneath the [key] (aka prefix).
  Future<Set<String>> list(String key);
}
