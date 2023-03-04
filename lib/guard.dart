/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'cache/license/license_use.dart';
import 'cache/license/license_usecase.dart';
import 'license_record.dart';

/// @nodoc
class Guard {
  /// Checks if a [license] is valid and if the [uses] are permitted
  static String? check(LicenseRecord license, List<LicenseUse> uses) {
    if (license.uses.isEmpty) return 'No uses in LicenseRecord';
    if (!_checkExpiry(license)) return 'License expired: ${license.expiry}';

    List<LicenseUse> flatUses = _flatten(uses);
    List<LicenseUse> flatExpect = _flatten(license.uses);

    for (LicenseUse use in flatUses) {
      bool pass = false;
      for (LicenseUse expect in flatExpect) {
        if (_checkUse(expect, use)) {
          pass = true;
          break;
        }
      }
      if (pass == false) return 'Invalid use: ${use.toString()}';
    }
    return null;
  }

  /// Checks if a [license] is expired
  static bool _checkExpiry(LicenseRecord license) {
    if (license.expiry != null) {
      if (license.expiry!.isBefore(DateTime.now())) return false;
    }
    return true;
  }

  /// Checks if [actual] meets the criteria of [expect]
  static bool _checkUse(LicenseUse expect, LicenseUse actual) {
    if (!_checkUsecases(expect.usecases, actual.usecases)) return false;
    if (!_checkDestinations(expect.destinations, actual.destinations)) {
      return false;
    }
    return true;
  }

  /// Checks if each [LicenseUsecase] in [actual] meets one of the
  /// RegEx [LicenseUsecase]s in [expect]
  static bool _checkUsecases(
      List<LicenseUsecase> expect, List<LicenseUsecase> actual) {
    List<String> expectValues = expect.map((usecase) => usecase.value).toList();
    for (LicenseUsecase test in actual) {
      if (!expectValues.contains(test.value)) return false;
    }
    return true;
  }

  /// Checks each String in [actual] meets one of the RegEx Strings in [expect]
  static bool _checkDestinations(List<String>? expect, List<String>? actual) {
    if (expect == null) return true;
    if (actual == null) return false;
    for (String test in actual) {
      for (String regex in expect) {
        if (RegExp(regex).hasMatch(test)) return true;
      }
    }
    return false;
  }

  /// Flattens the multi-list structure of [original] to
  /// a List of single LicenseUsecase <> Destination pairings.
  static List<LicenseUse> _flatten(List<LicenseUse> original) {
    List<LicenseUse> flat = [];
    for (LicenseUse use in original) {
      if (use.destinations == null) {
        flat.addAll(
            use.usecases.map((usecase) => LicenseUse([usecase])).toList());
      } else {
        for (LicenseUsecase usecase in use.usecases) {
          for (String destination in use.destinations!) {
            flat.add(LicenseUse([usecase], destinations: [destination]));
          }
        }
      }
    }
    return flat;
  }
}
