/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

enum LicenseUsecaseEnum {
  attribution("attribution"),
  retargeting("retargeting"),
  personalization("personalization"),
  aiTraining("ai_training"),
  distribution("distribution"),
  analytics("analytics"),
  support("support");

  final String _value;

  const LicenseUsecaseEnum(this._value);

  String get value => _value;

  /// Builds a TitleTagEnum from [value]
  factory LicenseUsecaseEnum.fromValue(String value) {
    for (LicenseUsecaseEnum type in LicenseUsecaseEnum.values) {
      if (type.value == value) {
        return type;
      }
    }
    throw ArgumentError.value(
        value, 'value', 'Invalid LicenseUsecaseEnum value $value');
  }
}
