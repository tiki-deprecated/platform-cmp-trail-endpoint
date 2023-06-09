/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'license_record.dart';

/// Payable Records describe a payment issued or owed in accordance with
/// the terms of a [LicenseRecord].
class PayableRecord {
  /// This record's id
  String? id;

  /// The [LicenseRecord] for this license
  LicenseRecord license;

  /// The total amount. Can be a simple numeric value, or an atypical value
  /// such as downloadable content.
  String amount;

  /// Describes the type of payment (e.g. loyalty-point, cash, coupon, etc.)
  String type;

  /// A human-readable description of the payable
  String? description;

  /// The date when the payable expires
  DateTime? expiry;

  /// A customer-specific reference identifier
  String? reference;

  PayableRecord(this.id, this.license, this.amount, this.type,
      {this.description, this.expiry, this.reference});
}
