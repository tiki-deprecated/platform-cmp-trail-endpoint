/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'cache/license/license_model.dart';
import 'cache/license/license_service.dart';
import 'tiki_sdk.dart';
import 'utils/bytes.dart';

/// Methods for creating and retrieving [LicenseRecord]s. Use like a namespace,
/// and call from [TikiSdk]. E.g. `tikiSdk.license.create(...)`.
class License {
  final LicenseService _licenseService;
  final TikiSdk _sdk;

  /// Use [TikiSdk] to construct.
  /// @nodoc
  License(this._licenseService, this._sdk);

  /// Create a new [LicenseRecord]
  ///
  /// Parameters:
  ///
  /// • [title] - The [TitleRecord] to attach the license to.
  ///
  /// • [uses] - A `List` defining how and where an asset may be used, in a
  /// the format of usecases and destinations, per the [terms] of the license.
  /// [Learn more](https://docs.mytiki.com/docs/specifying-terms-and-usage)
  ///  about defining uses.
  ///
  /// • [terms] - The legal terms of the contract — typically text or
  /// markdown, but can a be a URI to externally hosted terms.
  ///
  /// • [description] - An optional, short, human-readable,
  /// description of the [LicenseRecord].
  ///
  /// • [expiry] - A [LicenseRecord] expiration date. Leave `null` if the
  /// license never expires.
  ///
  /// Returns the created [LicenseRecord]
  Future<LicenseRecord> create(
      TitleRecord title, List<LicenseUse> uses, String terms,
      {String? description, DateTime? expiry}) async {
    LicenseModel license = await _licenseService.create(
        Bytes.base64UrlDecode(title.id), uses, terms,
        description: description, expiry: expiry);
    return license.toRecord(title);
  }

  /// Returns the latest [LicenseRecord] for a [title] or null if no
  /// license records are not found.
  ///
  /// The [LicenseRecord] returned may be expired or not applicable to a
  /// specific [LicenseUse]. To check license validity, use the [guard]
  /// method.
  LicenseRecord? latest(TitleRecord title) {
    LicenseModel? license =
        _licenseService.getLatest(Bytes.base64UrlDecode(title.id));
    if (license == null) return null;
    return license.toRecord(title);
  }

  /// Returns all [LicenseRecord]s for a [title].
  ///
  /// The [LicenseRecord]s returned may be expired or not applicable to a
  /// specific [LicenseUse]. To check license validity, use the [guard]
  /// method.
  List<LicenseRecord> all(TitleRecord title) {
    List<LicenseModel> licenses =
        _licenseService.getAll(Bytes.base64UrlDecode(title.id));
    return licenses.map((license) => license.toRecord(title)).toList();
  }

  /// Returns the [LicenseRecord] with a specific [id] or null if the license
  /// is not found.
  LicenseRecord? get(String id) {
    LicenseModel? license = _licenseService.getById(Bytes.base64UrlDecode(id));
    if (license == null) return null;
    TitleRecord? title = _sdk.title.id(Bytes.base64UrlEncode(license.title));
    if (title == null) return null;
    return license.toRecord(title);
  }
}
