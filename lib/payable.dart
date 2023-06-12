/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:typed_data';

import 'cache/payable/payable_model.dart';
import 'cache/payable/payable_service.dart';
import 'tiki_trail.dart';
import 'utils/bytes.dart';

/// Methods for creating and retrieving [PayableRecord]s. Use like a namespace,
/// and call from [TikiTrail]. E.g. `tikiTrail.payable.create(...)`.
class Payable {
  final PayableService _payableService;
  final TikiTrail _trail;

  /// Use [TikiTrail] to construct.
  /// @nodoc
  Payable(this._payableService, this._trail);

  /// Create a new [PayableRecord].
  ///
  /// Parameters:
  ///
  /// • [license] - The [LicenseRecord] to attach the license to.
  ///
  /// • [amount] - The total amount to be paid. Can be a simple numeric value,
  /// or an atypical value such as downloadable content.
  ///
  /// • [type] - Describes the type of payment (e.g. loyalty-point, cash,
  /// coupon, etc.)
  ///
  /// • [description] - An optional, short, human-readable, description of
  /// the [PayableRecord] as a future reminder.
  ///
  /// • [expiry] - The date when the payable expires — leave `null` if
  /// it never expires.
  ///
  /// • [reference] - A customer-specific reference identifier. Use this
  /// to connect the record to your system.
  ///
  /// Returns the created [PayableRecord]
  Future<PayableRecord> create(
      LicenseRecord license, String amount, String type,
      {String? description, DateTime? expiry, String? reference}) async {
    Uint8List licenseId = Bytes.base64UrlDecode(license.id!);
    PayableModel payable = await _payableService.create(licenseId, amount, type,
        description: description, expiry: expiry, reference: reference);
    return payable.toRecord(license);
  }

  /// Returns all [PayableRecord]s for a [license].
  List<PayableRecord> all(LicenseRecord license) {
    Uint8List licenseId = Bytes.base64UrlDecode(license.id!);
    List<PayableModel> payables = _payableService.getAll(licenseId);
    return payables.map((payable) => payable.toRecord(license)).toList();
  }

  /// Returns the [PayableRecord] with a specific [id] or null if the payable
  /// is not found.
  PayableRecord? get(String id) {
    PayableModel? payable = _payableService.getById(Bytes.base64UrlDecode(id));
    if (payable == null) return null;
    LicenseRecord? license =
        _trail.license.get(Bytes.base64UrlEncode(payable.license));
    if (license == null) return null;
    return payable.toRecord(license);
  }
}
