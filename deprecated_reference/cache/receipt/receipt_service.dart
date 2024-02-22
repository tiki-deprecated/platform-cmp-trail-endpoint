/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:typed_data';

import '../../node/node_service.dart';
import '../../node/transaction/transaction_model.dart';
import '../../utils/bytes.dart';
import '../content_schema.dart';
import 'receipt_model.dart';
import 'receipt_repository.dart';

/// The service to manage [ReceiptModel]s
class ReceiptService {
  final ReceiptRepository _repository;
  final NodeService _nodeService;

  ReceiptService(db, this._nodeService) : _repository = ReceiptRepository(db);

  /// Create a new on-chain [PayableModel]
  ///
  /// This method creates a new pending transaction that will be committed
  /// during assembly of the next block in the chain.
  Future<ReceiptModel> create(Uint8List payable, String amount,
      {String? description, DateTime? expiry, String? reference}) async {
    ReceiptModel receipt = ReceiptModel(payable, amount,
        description: description, reference: reference);

    Uint8List contents = (BytesBuilder()
          ..add(ContentSchema.receipt.toCompactSize())
          ..add(receipt.serialize()))
        .toBytes();

    String assetRef = "txn://${Bytes.base64UrlEncode(payable)}";
    TransactionModel transaction =
        await _nodeService.write(contents, assetRef: assetRef);

    receipt.timestamp = transaction.timestamp;
    receipt.transactionId = transaction.id!;
    _repository.save(receipt);
    return receipt;
  }

  /// Returns the payable for a [id]
  ReceiptModel? getById(Uint8List id) => _repository.getById(id);

  /// Returns all payables given a [payable]
  List<ReceiptModel> getAll(Uint8List payable) =>
      _repository.getByPayable(payable);

  void tryAdd(ReceiptModel receipt) {
    if (receipt.transactionId != null) {
      ReceiptModel? found = _repository.getById(receipt.transactionId!);
      if (found == null) {
        _repository.save(receipt);
      }
    }
  }
}
