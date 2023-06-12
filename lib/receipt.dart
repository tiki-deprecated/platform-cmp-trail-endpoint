/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:typed_data';

import 'cache/receipt/receipt_model.dart';
import 'cache/receipt/receipt_service.dart';
import 'tiki_trail.dart';
import 'utils/bytes.dart';

/// Methods for creating and retrieving [ReceiptRecord]s. Use like a namespace,
/// and call from [TikiTrail]. E.g. `tikiTrail.receipt.create(...)`.
class Receipt {
  final ReceiptService _receiptService;
  final TikiTrail _trail;

  /// Use [TikiTrail] to construct.
  /// @nodoc
  Receipt(this._receiptService, this._trail);

  /// Create a new [ReceiptRecord].
  ///
  /// Parameters:
  ///
  /// • [payable] - The [PayableRecord] to attach the receipt to.
  ///
  /// • [amount] - The total amount paid. Can be a simple numeric value,
  /// or an atypical value such as downloadable content.
  ///
  /// • [description] - An optional, short, human-readable, description of
  /// the [ReceiptRecord].
  ///
  /// • [reference] - A customer-specific reference identifier. Use this
  /// to connect the record to your system.
  ///
  /// Returns the created [ReceiptRecord]
  Future<ReceiptRecord> create(PayableRecord payable, String amount,
      {String? description, String? reference}) async {
    Uint8List payableId = Bytes.base64UrlDecode(payable.id!);
    ReceiptModel receipt = await _receiptService.create(payableId, amount,
        description: description, reference: reference);
    return receipt.toRecord(payable);
  }

  /// Returns all [ReceiptRecord]s for a [payable].
  List<ReceiptRecord> all(PayableRecord payable) {
    Uint8List payableId = Bytes.base64UrlDecode(payable.id!);
    List<ReceiptModel> receipts = _receiptService.getAll(payableId);
    return receipts.map((receipt) => receipt.toRecord(payable)).toList();
  }

  /// Returns the [ReceiptRecord] with a specific [id] or null if the receipt
  /// is not found.
  ReceiptRecord? get(String id) {
    ReceiptModel? receipt = _receiptService.getById(Bytes.base64UrlDecode(id));
    if (receipt == null) return null;
    PayableRecord? payable =
        _trail.payable.get(Bytes.base64UrlEncode(receipt.payable));
    if (payable == null) return null;
    return receipt.toRecord(payable);
  }
}
