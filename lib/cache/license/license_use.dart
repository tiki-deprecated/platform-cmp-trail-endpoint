/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import '../../license_record.dart';
import 'license_usecase.dart';

/// Define explicit uses for an asset. [LicenseUse]s are extremely helpful
/// in programmatic search and enforcement of your [LicenseRecord]s.
///
/// [usecases] explicitly define HOW an asset may be used. Use either our
/// list of common enumerations or define your own using
/// [LicenseUsecase.custom]
///
/// [destinations] define WHO can use an asset. [destinations] narrow down
/// [usecases] to a set of URLs, categories of companies, or more. Use
/// ECMAScript Regex to specify flexible and easily enforceable rules.
///
class LicenseUse {
  /// Usecases explicitly define HOW an asset may be used.
  List<LicenseUsecase> usecases;

  /// Destinations explicitly define WHERE an asset may be used.
  /// Destinations can be either explicit (`'https://mytiki.com'`) or
  /// ECMAScript Compatible Regex (`'\\.mytiki\\.com'`)
  List<String>? destinations;

  LicenseUse(this.usecases, {this.destinations});

  /// Construct a [LicenseUse] from a [map].
  ///
  /// Primary use is repository object marshalling.
  LicenseUse.fromMap(Map<String, dynamic> map)
      : usecases = map["usecases"]
            .map<LicenseUsecase>((usecase) => LicenseUsecase.from(usecase))
            .toList(),
        destinations = map["destinations"] != null
            ? List<String>.from(map["destinations"])
            : null;

  /// Converts this to Map
  ///
  /// Primary use is repository object marshalling.
  Map toMap() => {
        "usecases": usecases.map((usecase) => usecase.value).toList(),
        "destinations": destinations
      };

  @override
  String toString() {
    return 'LicenseUse{usecases: ${usecases.map((usecase) => usecase.value).toList()}, destinations: $destinations}';
  }
}
