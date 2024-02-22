/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:typed_data';

import '../utils/bytes.dart';
import '../utils/compact_size.dart';

/// A schema identifier for a transaction's contents
enum ContentSchema {
  title(2),
  license(3),
  payable(4),
  receipt(5);

  final int _value;

  const ContentSchema(this._value);

  /// Builds a ContentSchemaEnum from [value]
  factory ContentSchema.fromValue(int value) {
    for (ContentSchema type in ContentSchema.values) {
      if (type._value == value) {
        return type;
      }
    }
    throw ArgumentError.value(
        value, 'value', 'Invalid ContentSchema value $value');
  }

  /// Returns the schema's numerical representation
  int get value => _value;

  /// Returns this as a compact size
  Uint8List toCompactSize() =>
      CompactSize.encode(Bytes.encodeBigInt(BigInt.from(_value)));

  //pass in bytes and get back a content schema, but you also need to strip off the bytes
  //
}
