/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'cache/license/license_use.dart';
import 'title_record.dart';

/// License Records describe the terms around which a data asset may be used
/// and MUST contain a reference to the corresponding Title Record.
/// [Learn more](https://docs.mytiki.com/docs/offer-customization) about
/// License Records.
class LicenseRecord {
  /// This record's id
  String? id;

  /// The [TitleRecord] for this license
  TitleRecord title;

  /// A list describing how an asset can be used
  List<LicenseUse> uses;

  /// The legal terms for the license
  String terms;

  /// A human-readable description of the license
  String? description;

  /// The date when the license expires
  DateTime? expiry;

  LicenseRecord(this.id, this.title, this.uses, this.terms,
      {this.description, this.expiry});
}
