/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'cache/license/license_use.dart';
import 'title_record.dart';

/// License Records describe the terms around how a data asset may be used and
/// always contain a reference to a corresponding [TitleRecord].
class LicenseRecord {
  /// This record's id.
  String? id;

  /// The [TitleRecord] for this license.
  TitleRecord title;

  /// A list of metadata use cases describing how/where the asset can be used
  /// [Learn more](https://docs.mytiki.com/docs/specifying-terms-and-usage)
  /// about defining uses.
  List<LicenseUse> uses;

  /// The legal terms for the license — text, markdown, or a uri.
  String terms;

  /// An optional, human-readable description of the license.
  String? description;

  /// The date when the license expires — null if it never expires.
  DateTime? expiry;

  LicenseRecord(this.id, this.title, this.uses, this.terms,
      {this.description, this.expiry});
}
