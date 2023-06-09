/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:typed_data';

import 'cache/payable/payable_model.dart';
import 'cache/payable/payable_service.dart';
import 'license.dart';
import 'license_record.dart';
import 'payable_record.dart';
import 'utils/bytes.dart';

class Payable {
  final PayableService _payableService;
  final License _license;

  Payable(this._payableService, this._license);

  Future<PayableRecord> create(String ptr, String amount, String type,
      {String? description,
      DateTime? expiry,
      String? reference,
      String? origin}) async {
    LicenseRecord? license = _license.latest(ptr, origin: origin);
    if (license == null) {
      throw StateError("Failed to create Payable. No license found for Ptr.");
    }
    Uint8List licenseId = Bytes.base64UrlDecode(license.id!);
    PayableModel payable = await _payableService.create(licenseId, amount, type,
        description: description, expiry: expiry, reference: reference);
    return payable.toRecord(license);
  }

  List<PayableRecord> all(String ptr, {String? origin}) {
    LicenseRecord? license = _license.latest(ptr, origin: origin);
    if (license == null) return List.empty();
    Uint8List licenseId = Bytes.base64UrlDecode(license.id!);
    List<PayableModel> payables = _payableService.getAll(licenseId);
    return payables.map((payable) => payable.toRecord(license)).toList();
  }

  PayableRecord? get(String id) {
    PayableModel? payable = _payableService.getById(Bytes.base64UrlDecode(id));
    if (payable == null) return null;
    LicenseRecord? license =
        _license.get(Bytes.base64UrlEncode(payable.license));
    if (license == null) return null;
    return payable.toRecord(license);
  }
}
