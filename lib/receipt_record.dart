/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'license_record.dart';
import 'payable_record.dart';

/// Payable Records describe a payment issued or owed in accordance with
/// the terms of a [LicenseRecord].
class ReceiptRecord {
  /// This record's id
  String? id;

  /// The [PayableRecord] for this receipt
  PayableRecord payable;

  /// The total amount. Can be a simple numeric value, or an atypical value
  /// such as downloadable content.
  String amount;

  /// A human-readable description of the payable
  String? description;

  /// A customer-specific reference identifier
  String? reference;

  ReceiptRecord(this.id, this.payable, this.amount,
      {this.description, this.reference});
}
