/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:typed_data';

import '../../node/node_service.dart';
import '../../node/transaction/transaction_model.dart';
import '../../utils/bytes.dart';
import '../content_schema.dart';
import 'payable_model.dart';
import 'payable_repository.dart';

/// The service to manage [PayableModel]s
class PayableService {
  final PayableRepository _repository;
  final NodeService _nodeService;

  PayableService(db, this._nodeService) : _repository = PayableRepository(db);

  /// Create a new on-chain [PayableModel]
  ///
  /// This method creates a new pending transaction that will be committed
  /// during assembly of the next block in the chain.
  Future<PayableModel> create(Uint8List license, String amount, String type,
      {String? description, DateTime? expiry, String? reference}) async {
    PayableModel payable = PayableModel(license, amount, type,
        description: description, expiry: expiry, reference: reference);

    Uint8List contents = (BytesBuilder()
          ..add(ContentSchema.payable.toCompactSize())
          ..add(payable.serialize()))
        .toBytes();

    String assetRef = "txn://${Bytes.base64UrlEncode(license)}";
    TransactionModel transaction =
        await _nodeService.write(contents, assetRef: assetRef);

    payable.timestamp = transaction.timestamp;
    payable.transactionId = transaction.id!;
    _repository.save(payable);
    return payable;
  }

  /// Returns the payable for a [id]
  PayableModel? getById(Uint8List id) => _repository.getById(id);

  /// Returns all payables given a [license]
  List<PayableModel> getAll(Uint8List license) =>
      _repository.getByLicense(license);

  void tryAdd(PayableModel payable) {
    if (payable.transactionId != null) {
      PayableModel? found = _repository.getById(payable.transactionId!);
      if (found == null) {
        _repository.save(payable);
      }
    }
  }
}
