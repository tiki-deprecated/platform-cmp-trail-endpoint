/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */
///
/// Handle Ownership NFTs.
library ownership;

import 'dart:typed_data';

import '../node/node_service.dart';
import '../tiki_sdk.dart';
import 'ownership_model.dart';
import 'ownership_repository.dart';

export 'ownership_model.dart';
export 'ownership_repository.dart';

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
  /// next block in the chain.
  /// If no [origin] is provided the default [origin] will be used
  Future<OwnershipModel> create(
      {required String source,
      required TikiSdkDataTypeEnum type,
      String? origin,
      String? about,
      List<String> contains = const []}) async {
    OwnershipModel? ownershipModel = getBySource(source, origin: origin);
    if (ownershipModel != null) {
      throw 'Ownership already granted for $source and $origin. ${ownershipModel.toString()}';
    }
    ownershipModel = OwnershipModel(
        source: source,
        type: type,
        origin: origin ?? _defaultOrigin,
        contains: contains);
    Uint8List contents = (BytesBuilder()
          ..addByte(1)
          ..addByte(1)
          ..add(ownershipModel.serialize()))
        .toBytes();
    TransactionModel transaction = await nodeService.write(contents);
    ownershipModel.transactionId = transaction.id;
    _repository.save(ownershipModel);
    return ownershipModel;
  }

  /// Gets a [OwnershipModel] by its [source] and [origin] from local database.
  ///
  /// If no [origin] is provided the [_defaultOrigin] will be used
  OwnershipModel? getBySource(String source, {String? origin}) =>
      _repository.getBySource(source, origin ?? _defaultOrigin);
}
