// ignore_for_file: unused_field

/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */
/// {@category SDK}

import 'dart:typed_data';

import '../node/node_service.dart';
import '../tiki_sdk.dart';
import 'ownership_model.dart';
import 'ownership_repository.dart';

/// The service to manage ownership registries.
class OwnershipService {
  /// The default origin for all ownerships.
  final String _defaultOrigin;

  final OwnershipRepository _repository;

  final NodeService nodeService;

  OwnershipService(this._defaultOrigin, this.nodeService, db)
      : _repository = OwnershipRepository(db);

  /// Creates a ownership register in the blockchain.
  ///
  /// This method creates a new transcation that will be commited in the
  /// next block in the chain. The [OwnershipModel.path] will be null until
  /// the transaction is commited through [updatePending].
  /// If no [origin] is provided the default [_origin] will be used
  Future<Uint8List> create(
      {required String source,
      required List<TikiSdkDataTypeEnum> types,
      String? origin,
      String? about}) async {
    OwnershipModel? ownershipModel = getBySource(source, origin: origin);
    if (ownershipModel != null) {
      throw 'Ownership already granted for $source and $origin. ${ownershipModel.toString()}';
    }
    ownershipModel = OwnershipModel(
        source: source, types: types, origin: origin ?? _defaultOrigin);
    Uint8List contents = (BytesBuilder()
          ..addByte(1)
          ..addByte(1)
          ..add(ownershipModel.serialize()))
        .toBytes();
    TransactionModel transaction = await nodeService.write(contents);
    ownershipModel.transactionId = transaction.id;
    _repository.save(ownershipModel);
    return ownershipModel.transactionId!;
  }

  /// Gets a [OwnershipModel] by its [source] and [origin] from local database.
  ///
  /// If no [origin] is provided the [_defaultOrigin] will be used
  OwnershipModel? getBySource(String source, {String? origin}) =>
      _repository.getBySource(source, origin ?? _defaultOrigin);
}
