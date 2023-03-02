/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'license_usecase_enum.dart';

/// Usecases explicitly define HOW an asset may be used.
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

  /// Add a custom usecase using the format of custom:<usecase>
  LicenseUsecase.custom(String customUsecase)
      : _value = "custom:$customUsecase";

  /// Builds a [LicenseUsecase] from [value]
  factory LicenseUsecase.from(String value) {
    try {
      LicenseUsecaseEnum usecase = LicenseUsecaseEnum.fromValue(value);
      return LicenseUsecase(usecase);
    } catch (e) {
      return LicenseUsecase.custom(value.replaceFirst('custom:', ''));
    }
  }

  /// Returns the string value for the usecase
  String get value => _value;
}
