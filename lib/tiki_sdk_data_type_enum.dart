/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

/// The type of data a stream, point or pool holds.
enum TikiSdkDataTypeEnum {
  point('data_point'),
  pool('data_pool'),
  stream('data_stream');

  const TikiSdkDataTypeEnum(this.val);

  /// Builds a TikiSdkDataTypeEnum from [value]
  ///
  /// Valid values are: data_point, data_pool, data_stream.
  factory TikiSdkDataTypeEnum.fromValue(String value) {
    for (TikiSdkDataTypeEnum type in TikiSdkDataTypeEnum.values) {
      if (type.val == value) {
        return type;
      }
    }
    throw ArgumentError.value(
        value, 'value', 'Invaid TikiSdkDataTypeEnum value $value');
  }

  final String val;
}
