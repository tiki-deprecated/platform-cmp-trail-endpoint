/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */
/// {@category SDK}
/// The type of data a stream, point or pool holds.
enum TikiSdkDataTypeEnum {
  point('data_point'),
  pool('data_pool'),
  stream('data_stream');

  const TikiSdkDataTypeEnum(this.val);

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
