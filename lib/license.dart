/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'cache/license/license_model.dart';
import 'cache/license/license_service.dart';
import 'tiki_sdk.dart';
import 'utils/bytes.dart';

class License {
  final LicenseService _licenseService;
  final TikiSdk _sdk;

  License(this._licenseService, this._sdk);

  /// Create a new [LicenseRecord].
  ///
  /// If a [TitleRecord] for the [ptr] and [origin] is not found. A new
  /// [TitleRecord] is created. If a [TitleRecord] is found, [tags] and
  /// [titleDescription] parameters are ignored.
  ///
  /// Parameters:
  ///
  /// • [ptr] - The Pointer Records identifies data stored in your system,
  /// similar to a foreign key.
  /// [Learn more](https://docs.mytiki.com/docs/selecting-a-pointer-record)
  /// about selecting good pointer records.
  ///
  /// • [uses] - A `List` defining how and where an asset may be used, in a
  /// the format of usecases and destinations, per the [terms] of the license.
  /// [Learn more](https://docs.mytiki.com/docs/specifying-terms-and-usage)
  /// about defining uses.
  ///
  /// • [terms] - The legal terms of the contract (a lot of words).
  ///
  /// • [origin] - An optional override of the default [origin] specified in
  /// [init]. Follow a reverse-DNS syntax. _i.e. com.myco.myapp_.
  ///
  /// • [tags] - A `List` of metadata tags included in the [TitleRecord]
  /// describing the asset, for your use in record search and filtering.
  /// [Learn more](https://docs.mytiki.com/docs/adding-tags)
  /// about adding tags. Only set IF a title does not already exist for the
  /// [ptr].
  ///
  /// • [titleDescription] - Sets the [TitleRecord] description IF a title
  /// does not already exist for the [ptr]. A short, human-readable,
  /// description of the [TitleRecord] as a future reminder.
  ///
  /// • [licenseDescription] - A short, human-readable,
  /// description of the [LicenseRecord] as a future reminder.
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

  /// Returns the latest [LicenseRecord] for a [ptr] or null if the
  /// title or license records are not found.
  ///
  /// Optionally, an [origin] may be specified. If null [origin] defaults
  /// to the [init] origin.
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

  /// Returns all [LicenseRecord]s for a [ptr].
  ///
  /// Optionally, an [origin] may be specified. If null [origin] defaults
  /// to the [init] origin.
  ///
  /// The [LicenseRecord]s returned may be expired or not applicable to a
  /// specific [LicenseUse]. To check license validity, use the [guard]
  /// method.
  List<LicenseRecord> all(TitleRecord title) {
    List<LicenseModel> licenses =
        _licenseService.getAll(Bytes.base64UrlDecode(title.id));
    return licenses.map((license) => license.toRecord(title)).toList();
  }

  /// Returns the [LicenseRecord] for an [id] or null if the license
  /// or corresponding title record is not found.
  LicenseRecord? get(String id) {
    LicenseModel? license = _licenseService.getById(Bytes.base64UrlDecode(id));
    if (license == null) return null;
    TitleRecord? title = _sdk.title.id(Bytes.base64UrlEncode(license.title));
    if (title == null) return null;
    return license.toRecord(title);
  }
}
