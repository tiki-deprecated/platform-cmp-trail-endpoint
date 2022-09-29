/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */
/// {@category SDK}
import 'dart:typed_data';

import '../node/node_service.dart';
import '../tiki_sdk_destination.dart';
import 'consent_repository.dart';
import 'cosent_model.dart';

/// The service to manage consent registries.
class ConsentService {
  final ConsentRepository _repository;

  final NodeService _nodeService;

  ConsentService(db, this._nodeService) : _repository = ConsentRepository(db);

  /// Modify consent for [source].
  ///
  /// Ownership must be granted before modifying consent.
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
    return _repository.getByOwnershipId(ownershipId)!;
  }

  ConsentModel? getByOwnershipId(Uint8List ownershipId) =>
      _repository.getByOwnershipId(ownershipId);
}
