/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:typed_data';

abstract class XChainClient {
  Future<Uint8List?> read(String key);
  Future<Set<String>> list(String key);
}
