/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:typed_data';

import 'package:collection/collection.dart';

class CryptoAESKey {
  late final Uint8List? key;

  CryptoAESKey(this.key);

  CryptoAESKey.decode(String encodedKey) : key = base64.decode(encodedKey);

  String encode() => base64.encode(key!);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CryptoAESKey &&
          runtimeType == other.runtimeType &&
          const ListEquality().equals(key, other.key);

  @override
  int get hashCode => key.hashCode;

  @override
  String toString() {
    return 'CryptoAESKey{key: *****}';
  }
}
