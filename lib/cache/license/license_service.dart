/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */
/// Manage License Records
/// {@category Cache}
library license;

import 'dart:convert';
import 'dart:typed_data';

import '../../node/node_service.dart';
import '../../node/transaction/transaction_model.dart';
import '../content_schema.dart';
import 'license_record.dart';
import 'license_repository.dart';
import 'license_use.dart';

/// The service to manage [LicenseRecord]s
class LicenseService {
  final LicenseRepository _repository;

  final NodeService _nodeService;

  LicenseService(db, this._nodeService) : _repository = LicenseRepository(db);

  /// Create a new on-chain [LicenseRecord]
  ///
  /// This method creates a new pending transaction that will be committed
  /// during assembly of the next block in the chain.
  Future<LicenseRecord> create(
      Uint8List title, List<LicenseUse> uses, String terms,
      {String? description, DateTime? expiry}) async {
    LicenseRecord license = LicenseRecord(title, uses, terms,
        description: description, expiry: expiry);

    Uint8List contents = (BytesBuilder()
          ..add(ContentSchema.license.toCompactSize())
          ..add(license.serialize()))
        .toBytes();
    TransactionModel transaction =
        await _nodeService.write(contents, assetRef: base64.encode(title));

    license.transactionId = transaction.id!;
    _repository.save(license);
    return license;
  }

  /// Returns the latest consent for a [title].
  LicenseRecord? getByTitle(Uint8List title) => _repository.getByTitle(title);
}
