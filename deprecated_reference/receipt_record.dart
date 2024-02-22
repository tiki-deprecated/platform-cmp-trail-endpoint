/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'payable_record.dart';

/// Receipt Records describe a payment or partial-payment in accordance with
/// a [PayableRecord].
class ReceiptRecord {
  /// This record's id
  String? id;

  /// The [PayableRecord] for this receipt
  PayableRecord payable;

  /// The total amount. Can be a simple numeric value, or an atypical value
  /// such as downloadable content.
  String amount;

  /// An optional, human-readable description of the payable
  String? description;

  /// An optional, customer-specific reference identifier. Use to connect
  /// the record to your system.
  String? reference;

  /// The date when the record was created
  DateTime? timestamp;

  ReceiptRecord(this.id, this.payable, this.amount,
      {this.description, this.reference, this.timestamp});
}
