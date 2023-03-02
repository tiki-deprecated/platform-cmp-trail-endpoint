/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'license_usecase.dart';

class LicenseUse {
  /// Usecases explicitly define HOW an asset may be used.
  List<LicenseUsecase> usecases;

  /// Destinations explicitly define WHERE an asset may be used.
  /// Destinations can be: a wildcard URL (*.your-co.com),
  /// a string defining a category of destinations (data marketplaces),
  /// or prefixed by NOT, to explicitly deny specific destinations
  /// (NOT *.enemy.com).
  List<String>? destinations;

  LicenseUse(this.usecases, {this.destinations});

  /// Construct a [LicenseUse] from a [map].
  ///
  /// Primary use is [LicenseRepository] object marshalling.
  LicenseUse.fromMap(Map<String, dynamic> map)
      : usecases = map["usecases"]
            .map<LicenseUsecase>((usecase) => LicenseUsecase.from(usecase))
            .toList(),
        destinations = map["destinations"] != null
            ? List<String>.from(map["destinations"])
            : null;

  /// Converts this to Map
  ///
  /// Primary use is [LicenseRepository] object marshalling.
  Map toMap() => {
        "usecases": usecases.map((usecase) => usecase.value).toList(),
        "destinations": destinations
      };
}
