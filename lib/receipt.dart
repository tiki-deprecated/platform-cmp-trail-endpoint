/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:typed_data';

import 'cache/receipt/receipt_model.dart';
import 'cache/receipt/receipt_service.dart';
import 'receipt_record.dart';
import 'tiki_sdk.dart';
import 'utils/bytes.dart';

class Receipt {
  final ReceiptService _receiptService;
  final TikiSdk _sdk;

  Receipt(this._receiptService, this._sdk);

  Future<ReceiptRecord> create(PayableRecord payable, String amount,
      {String? description, String? reference}) async {
    Uint8List payableId = Bytes.base64UrlDecode(payable.id!);
    ReceiptModel receipt = await _receiptService.create(payableId, amount,
        description: description, reference: reference);
    return receipt.toRecord(payable);
  }

  List<ReceiptRecord> all(PayableRecord payable) {
    Uint8List payableId = Bytes.base64UrlDecode(payable.id!);
    List<ReceiptModel> receipts = _receiptService.getAll(payableId);
    return receipts.map((receipt) => receipt.toRecord(payable)).toList();
  }

  ReceiptRecord? get(String id) {
    ReceiptModel? receipt = _receiptService.getById(Bytes.base64UrlDecode(id));
    if (receipt == null) return null;
    PayableRecord? payable =
        _sdk.payable.get(Bytes.base64UrlEncode(receipt.payable));
    if (payable == null) return null;
    return receipt.toRecord(payable);
  }
}
