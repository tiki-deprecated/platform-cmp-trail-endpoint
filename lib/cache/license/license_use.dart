/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'license_usecase.dart';

class LicenseUse {
  List<LicenseUsecase> usecases;
  List<String>? destinations;

  LicenseUse(this.usecases, {this.destinations});

  LicenseUse.fromMap(Map<String, dynamic> map)
      : usecases = map["usecases"]
            .map<LicenseUsecase>((usecase) => LicenseUsecase.from(usecase))
            .toList(),
        destinations = map["destinations"] != null
            ? List<String>.from(map["destinations"])
            : null;

  Map toMap() => {
        "usecases": usecases.map((usecase) => usecase.value).toList(),
        "destinations": destinations
      };
}
