import 'dart:typed_data';

import '../tiki_sdk_destination.dart';
import '../utils/compact_size.dart';
import 'consent_repository.dart';

class ConsentModel {
  /// Transaction ID corresponding to the ownership mint for the data source.
  Uint8List assetRef;

  /// The ideintifier of where the
  TikiSdkDestination destination;

  /// Optional description of the consent.
  String? about;

  /// Optional reward description the user will receive for this consent.
  String? reward;

  /// The transaction id of this registry.
  Uint8List? transactionId;

  ConsentModel(this.assetRef, this.destination, {this.about, this.reward});

  ConsentModel.fromMap(Map<String, dynamic> map)
      : assetRef = map[ConsentRepository.columnAssetRef],
        destination = TikiSdkDestination.fromJson(
            map[ConsentRepository.columnDestination]),
        about = map[ConsentRepository.columnAbout],
        reward = map[ConsentRepository.columnReward],
        transactionId = map[ConsentRepository.columnTransactionId];

  Uint8List serialize() {
    return (BytesBuilder()
          ..add(CompactSize.encode(assetRef))
          ..add(CompactSize.encode(destination.serialize()))
          ..add(CompactSize.encode(about == null
              ? Uint8List(1)
              : Uint8List.fromList(about!.codeUnits)))
          ..add(CompactSize.encode(reward == null
              ? Uint8List(1)
              : Uint8List.fromList(reward!.codeUnits))))
        .toBytes();
  }

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
