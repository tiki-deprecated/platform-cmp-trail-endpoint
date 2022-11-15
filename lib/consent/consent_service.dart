/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */
/// Handle Consent NFTs.
library consent;

import 'dart:typed_data';

import '../node/node_service.dart';
import '../tiki_sdk_destination.dart';
import 'consent_model.dart';
import 'consent_repository.dart';

export 'consent_model.dart';
export 'consent_repository.dart';

/// The service to manage consent registries.
class ConsentService {
  final ConsentRepository _repository;

  final NodeService _nodeService;

  ConsentService(db, this._nodeService) : _repository = ConsentRepository(db);

  /// Modify consent for a [OwnershipModel] by its [ownershipId].
  Future<ConsentModel> modify(Uint8List ownershipId,
      {String? about,
      String? reward,
      DateTime? expiry,
      TikiSdkDestination destination = const TikiSdkDestination.all()}) async {
    ConsentModel consentModel = ConsentModel(ownershipId, destination,
        about: about, reward: reward, expiry: expiry);
    Uint8List contents = consentModel.serialize();
    TransactionModel transaction = await _nodeService.write(contents);
    consentModel.transactionId = transaction.id!;
    _repository.save(consentModel);
    return consentModel;
  }

  /// Gets a consent by its [ownershipId].
  ConsentModel? getByOwnershipId(Uint8List ownershipId) =>
      _repository.getByOwnershipId(ownershipId);
}
