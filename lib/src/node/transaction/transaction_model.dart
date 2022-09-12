import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/api.dart';

import '../../utils/bytes.dart';
import '../block/block_model.dart';
import '../../utils/compact_size.dart' as compactSize;

/// A transaction in the blockchain.
class TransactionModel {
  late final int version;
  late final Uint8List address;
  late final DateTime timestamp;
  late final String assetRef;
  late final Uint8List contents;

  int? seq;
  Uint8List? id;
  Uint8List? merkelProof;
  BlockModel? block;
  Uint8List? signature;

  TransactionModel(
      {this.seq,
      this.id,
      this.version = 1,
      required this.address,
      required this.contents,
      assetRef,
      timestamp,
      this.merkelProof,
      this.block}) {
    this.timestamp = timestamp ?? DateTime.now();
    this.assetRef = assetRef ?? "AA==";
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
        timestamp =
            DateTime.fromMillisecondsSinceEpoch(map['timestamp'] * 1000),
        signature = map['signature'];

  static TransactionModel fromJson(String json) =>
      TransactionModel.fromMap(jsonDecode(json));

  TransactionModel.deserialize(Uint8List transaction) {
    List<Uint8List> extractedBytes = compactSize.decode(transaction);
    version = decodeBigInt(extractedBytes[0]).toInt();
    address = extractedBytes[1];
    timestamp = DateTime.fromMillisecondsSinceEpoch(
        decodeBigInt(extractedBytes[2]).toInt() * 1000);
    assetRef = base64.encode(extractedBytes[3]);
    signature = extractedBytes[4];
    contents = extractedBytes[5];
    id = Digest("SHA3-256").process(serialize());
  }

  Uint8List serialize({includeSignature = true}) {
    Uint8List versionBytes = encodeBigInt(BigInt.from(version));
    Uint8List serializedVersion = (BytesBuilder()
          ..add(compactSize.toSize(versionBytes))
          ..add(versionBytes))
        .toBytes();
    Uint8List serializedAddress = (BytesBuilder()
          ..add(compactSize.toSize(address))
          ..add(address))
        .toBytes();
    Uint8List timestampBytes =
        encodeBigInt(BigInt.from(timestamp.millisecondsSinceEpoch ~/ 1000));
    Uint8List serializedTimestamp = (BytesBuilder()
          ..add(compactSize.toSize(timestampBytes))
          ..add(timestampBytes))
        .toBytes();
    Uint8List assetRefBytes = base64.decode(assetRef);
    Uint8List serializedAssetRef = (BytesBuilder()
          ..add(compactSize.toSize(assetRefBytes))
          ..add(assetRefBytes))
        .toBytes();
    Uint8List serializedSignature = (BytesBuilder()
          ..add(compactSize.toSize(includeSignature && signature != null
              ? signature!
              : Uint8List(0)))
          ..add(includeSignature && signature != null
              ? signature!
              : Uint8List(0)))
        .toBytes();
    Uint8List serializedContents = (BytesBuilder()
          ..add(compactSize.toSize(contents))
          ..add(contents))
        .toBytes();
    return (BytesBuilder()
          ..add(serializedVersion)
          ..add(serializedAddress)
          ..add(serializedTimestamp)
          ..add(serializedAssetRef)
          ..add(serializedSignature)
          ..add(serializedContents))
        .toBytes();
  }

  String toJson() {
    return jsonEncode({
      'seq': seq,
      'id': id,
      'version': version,
      'address': address,
      'contents': contents,
      'asset_ref': assetRef,
      'merkel_proof': merkelProof,
      'block': block,
      'timestamp': timestamp,
      'signature': signature,
    });
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => toJson();
}
