/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */
/// Handle Consent NFTs.
library consent;

import 'dart:typed_data';

import '../node/node_service.dart';
import '../tiki_sdk_destination.dart';
import 'consent_repository.dart';
import 'consent_model.dart';

export 'consent_repository.dart';
export 'consent_model.dart';

/// The service to manage consent registries.
class ConsentService {
  final ConsentRepository _repository;

  final NodeService _nodeService;

  ConsentService(db, this._nodeService) : _repository = ConsentRepository(db);

  /// Modify consent for a [OwnershipModel] by its [ownershipId].
  Future<ConsentModel> create(Uint8List ownershipId,
      {String? about,
      String? reward,
      TikiSdkDestination destinations = const TikiSdkDestination.all()}) async {
    ConsentModel consentModel =
        ConsentModel(ownershipId, destinations, about: about, reward: reward);
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
