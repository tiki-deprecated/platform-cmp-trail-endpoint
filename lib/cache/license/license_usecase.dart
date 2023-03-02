/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'license_usecase_enum.dart';

class LicenseUsecase {
  final String _value;

  LicenseUsecase(LicenseUsecaseEnum usecase) : _value = usecase.value;
  LicenseUsecase.attribution() : _value = LicenseUsecaseEnum.attribution.value;
  LicenseUsecase.retargeting() : _value = LicenseUsecaseEnum.retargeting.value;
  LicenseUsecase.personalization()
      : _value = LicenseUsecaseEnum.personalization.value;
  LicenseUsecase.aiTraining() : _value = LicenseUsecaseEnum.aiTraining.value;
  LicenseUsecase.distribution()
      : _value = LicenseUsecaseEnum.distribution.value;
  LicenseUsecase.analytics() : _value = LicenseUsecaseEnum.analytics.value;
  LicenseUsecase.support() : _value = LicenseUsecaseEnum.support.value;
  LicenseUsecase.custom(String customUsecase)
      : _value = "custom:$customUsecase";

  factory LicenseUsecase.from(String value) {
    try {
      LicenseUsecaseEnum usecase = LicenseUsecaseEnum.fromValue(value);
      return LicenseUsecase(usecase);
    } catch (e) {
      return LicenseUsecase.custom(value);
    }
  }

  String get value => _value;
}
