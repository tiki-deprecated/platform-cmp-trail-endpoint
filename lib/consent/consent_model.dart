/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */
import 'dart:typed_data';

import '../tiki_sdk_destination.dart';
import '../utils/compact_size.dart';
import 'consent_repository.dart';

/// The Consent NFT data structure
class ConsentModel {

  /// Transaction ID corresponding to the ownership mint for the data source.
  Uint8List ownershipId;

  /// The ideintifier of where the
  TikiSdkDestination destination;

  /// Optional description of the consent.
  String? about;

  /// Optional reward description the user will receive for this consent.
  String? reward;

  /// The transaction id of this registry.
  Uint8List? transactionId;

  /// Builds a [ConsentModel] using the [assetRef] for the
  ConsentModel(this.ownershipId, this.destination, {this.about, this.reward});

  ConsentModel.fromMap(Map<String, dynamic> map)
      : ownershipId = map[ConsentRepository.columnOwnershipId],
        destination = TikiSdkDestination.fromJson(
            map[ConsentRepository.columnDestination]),
        about = map[ConsentRepository.columnAbout],
        reward = map[ConsentRepository.columnReward],
        transactionId = map[ConsentRepository.columnTransactionId];

  /// Serializes the contents to be recorded in the blockchain.
  Uint8List serialize() {
    return (BytesBuilder()
          ..add(CompactSize.encode(ownershipId))
          ..add(CompactSize.encode(destination.serialize()))
          ..add(CompactSize.encode(about == null
              ? Uint8List(1)
              : Uint8List.fromList(about!.codeUnits)))
          ..add(CompactSize.encode(reward == null
              ? Uint8List(1)
              : Uint8List.fromList(reward!.codeUnits))))
        .toBytes();
  }


  /// Deserializes the contents that was loaded from the blockchain.
  static ConsentModel deserialize(Uint8List serialized) {
    List<Uint8List> unserialized = CompactSize.decode(serialized);
    return ConsentModel(
      unserialized[0],
      TikiSdkDestination.deserialize(unserialized[1]),
      about: String.fromCharCodes(unserialized[2]),
      reward: String.fromCharCodes(unserialized[3]),
    );
  }
}
