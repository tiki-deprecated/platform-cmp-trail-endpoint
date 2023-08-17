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

  /// An optional, human-readable description of the payable.
  String? description;

  /// The date when the payable expires — null if it never expires
  DateTime? expiry;

  /// An optional, customer-specific reference identifier. Use to connect
  /// the record to your system.
  String? reference;

  /// The date when the record was created
  DateTime? timestamp;

  PayableRecord(this.id, this.license, this.amount, this.type,
      {this.description, this.expiry, this.reference, this.timestamp});
}
