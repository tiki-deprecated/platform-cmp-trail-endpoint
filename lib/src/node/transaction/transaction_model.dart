import 'dart:typed_data';

import '../../utils/utils.dart';
import '../block/block_model.dart';

/// A transaction in the blockchain.
class TransactionModel {
  late final int version;
  late final Uint8List address;
  late final DateTime timestamp;
  late final Uint8List assetRef;
  late final Uint8List contents;

  int? seq;
  Uint8List? id;
  Uint8List? merkelProof;
  BlockModel? block;
  Uint8List? signature;

  TransactionModel({
    this.seq,
    this.id,
    this.version = 1,
    required this.address,
    required this.contents,
    assetRef,
    timestamp,
    this.merkelProof,
    this.block,
  }) {
    this.timestamp = timestamp ?? DateTime.now();
    this.assetRef = assetRef ?? Uint8List(1);
  }

  TransactionModel.fromMap(Map<String, dynamic> map)
      : seq = map['seq'],
        id = map['id'],
        version = map['version'],
        address = map['address'],
        contents = map['contents'],
        assetRef = map['asset_ref'],
        merkelProof = map['merkel_proof'],
        block = map['block'],
        timestamp = map['timestamp'],
        signature = map['signature'];

  String get uri {
    String txnId = uint8ListToBase64Url(id)!;
    return '${block!.uri}/$txnId';
  }

  @override
  String toString() => """TransactionModel{
      'seq': $seq
      'id': $id,
      'version': $version,
      'address': $address,
      'contents': $address,
      'asset_ref': assetRef,
      'merkel_proof': $merkelProof,
      'block': $block,
      'timestamp': $timestamp,
      'signature': $signature
    }
  }""";

  TransactionModel.deserialize(
    Uint8List transaction,
  ) {
    int currentPos = 0;
    List<Uint8List> parts = [];
    for (int i = 0; i < 5; i++) {
      int size = transaction[currentPos];
      currentPos++;
      int endPos = currentPos + size;
      parts.add(transaction.sublist(currentPos, endPos));
      currentPos = endPos;
    }
    version = decodeBigInt(parts[0]).toInt();
    address = parts[1];
    timestamp = DateTime.fromMillisecondsSinceEpoch(
        decodeBigInt(parts[2]).toInt() * 1000);
    assetRef = parts[3][0] == 0 ? Uint8List(1) : parts[3];
    signature = parts[4][0] == 0 ? null : parts[4];
    contents = transaction.sublist(currentPos + 2);
  }

  Uint8List serialize() {
    Uint8List serializedVersion = serializeInt(version);
    Uint8List serializedAddress =
        Uint8List.fromList([address.length, ...address]);
    Uint8List serializedTimestamp =
        serializeInt(timestamp.millisecondsSinceEpoch ~/ 1000);
    Uint8List serializedAssetRef =
        Uint8List.fromList([assetRef.length, ...assetRef]);
    Uint8List serializedSignature = Uint8List.fromList(
        signature != null ? [signature!.length, ...signature!] : [1, 0]);
    Uint8List serializedContents = Uint8List.fromList([1, 0, ...contents]);
    return Uint8List.fromList([
      ...serializedVersion,
      ...serializedAddress,
      ...serializedTimestamp,
      ...serializedAssetRef,
      ...serializedSignature,
      ...serializedContents,
    ]);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  toMap() {}
}
