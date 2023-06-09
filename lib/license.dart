/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'cache/license/license_model.dart';
import 'cache/license/license_service.dart';
import 'cache/license/license_use.dart';
import 'cache/license/license_usecase.dart';
import 'cache/title/title_tag.dart';
import 'license_record.dart';
import 'title.dart';
import 'title_record.dart';
import 'utils/bytes.dart';
import 'utils/guard.dart';

class License {
  final LicenseService _licenseService;
  final Title _title;

  License(this._licenseService, this._title);

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
  Future<LicenseRecord> create(String ptr, List<LicenseUse> uses, String terms,
      {String? origin,
      List<TitleTag> tags = const [],
      String? titleDescription,
      String? licenseDescription,
      DateTime? expiry}) async {
    TitleRecord? title = _title.get(ptr, origin: origin);
    title ??= await _title.create(ptr,
        origin: origin, tags: tags, description: titleDescription);
    LicenseModel license = await _licenseService.create(
        Bytes.base64UrlDecode(title.id), uses, terms,
        description: licenseDescription, expiry: expiry);
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
  LicenseRecord? latest(String ptr, {String? origin}) {
    TitleRecord? title = _title.get(ptr, origin: origin);
    if (title == null) return null;
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
  List<LicenseRecord> all(String ptr, {String? origin}) {
    TitleRecord? title = _title.get(ptr, origin: origin);
    if (title == null) return [];
    List<LicenseModel> licenses =
        _licenseService.getAll(Bytes.base64UrlDecode(title.id));
    return licenses.map((license) => license.toRecord(title)).toList();
  }

  /// Returns the [LicenseRecord] for an [id] or null if the license
  /// or corresponding title record is not found.
  LicenseRecord? get(String id) {
    LicenseModel? license = _licenseService.getById(Bytes.base64UrlDecode(id));
    if (license == null) return null;
    TitleRecord? title = _title.id(Bytes.base64UrlEncode(license.title));
    if (title == null) return null;
    return license.toRecord(title);
  }

  /// Guard against an invalid [LicenseRecord] for a List of [usecases] and
  /// [destinations].
  ///
  /// Use this method to verify a non-expired, [LicenseRecord] for the [ptr]
  /// exists, and permits the listed [usecases] and [destinations].
  ///
  /// Parameters:
  ///
  /// • [ptr] - The Pointer Record for the asset. Used to located the latest
  /// relevant [LicenseRecord].
  ///
  /// • [origin] - An optional override of the default [origin] specified in
  /// [init].
  ///
  /// • [usecases] - A List of usecases defining how the asset will be used.
  ///
  /// • [destinations] - A List of destinations defining where the asset will
  /// be used. _Often URLs_
  ///
  /// • [onPass] - A Function to execute automatically upon successfully
  /// resolving the [LicenseRecord] against the [usecases] and [destinations]
  ///
  /// • [onFail] - A Fucntion to execute automatically upon failure to resolve
  /// the [LicenseRecord]. Accepts a String parameter, holding an error
  /// message describing the reason for failure.
  ///
  /// This method can be used in two forms, 1) as a traditional guard,
  /// returning a pass/fail boolean. Or 2) as a wrapper around function.
  ///
  /// For example: An http that you want to run IF permitted by a
  /// [LicenseRecord].
  ///
  /// Option 1:
  /// ```
  /// bool pass = guard('ptr', [LicenseUsecase.attribution()]);
  /// if(pass) http.post(...);
  /// ```
  ///
  /// Option 2:
  /// ```
  /// guard('ptr', [LicenseUsecase.attribution()], onPass: () => http.post(...));
  /// ```
  ///
  /// Returns the created [TitleRecord]
  bool guard(String ptr, List<LicenseUsecase> usecases,
      {String? origin,
      List<String>? destinations,
      Function()? onPass,
      Function(String)? onFail}) {
    LicenseRecord? license = latest(ptr, origin: origin);
    if (license == null) {
      if (onFail != null) onFail('Missing license for ptr: $ptr');
      return false;
    }
    String? guardMessage = Guard.check(
        license, [LicenseUse(usecases, destinations: destinations)]);
    if (guardMessage == null) {
      if (onPass != null) onPass();
      return true;
    } else {
      if (onFail != null) onFail(guardMessage);
      return false;
    }
  }
}
