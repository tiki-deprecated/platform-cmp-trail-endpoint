import 'package:pointycastle/api.dart';

import '../../utils/bytes.dart';
import '../../utils/compact_size.dart' as compactSize;
import 'dart:typed_data';

class BlockModel {
  Uint8List? id;
  late int version;
  late Uint8List previousHash;
  late Uint8List transactionRoot;
  late int transactionCount;
  late final DateTime timestamp;

  BlockModel({
    this.version = 1,
    required this.previousHash,
    required this.transactionRoot,
    required this.transactionCount,
    timestamp,
  }) {
    this.timestamp = timestamp ?? DateTime.now();
  }

  BlockModel.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        version = map['version'],
        previousHash = map['previous_hash'],
        transactionRoot = map['transaction_root'],
        transactionCount = map['transaction_count'],
        timestamp =
            DateTime.fromMillisecondsSinceEpoch(map['timestamp'] * 1000);

  BlockModel.deserialize(Uint8List serialized) {
    List<Uint8List> extractedBlockBytes = compactSize.decode(serialized);
    version = decodeBigInt(extractedBlockBytes[0]).toInt();
    timestamp = DateTime.fromMillisecondsSinceEpoch(
        decodeBigInt(extractedBlockBytes[1]).toInt() * 1000);
    previousHash = extractedBlockBytes[2];
    transactionRoot = extractedBlockBytes[3];
    transactionCount = decodeBigInt(extractedBlockBytes[4]).toInt();
    if (extractedBlockBytes.sublist(5).length != transactionCount) {
      throw Exception(
          'Invalid transaction count. Expected $transactionCount. Got ${extractedBlockBytes.sublist(5).length}');
    }
    id = Digest("SHA3-256").process(header());
  }

  Uint8List serialize(Uint8List body) {
    Uint8List head = header();
    return (BytesBuilder()
          ..add(head)
          ..add(body))
        .toBytes();
  }

  Uint8List header() {
    Uint8List serializedVersion = encodeBigInt(BigInt.from(version));
    Uint8List serializedTimestamp = (BytesBuilder()
          ..add(encodeBigInt(
              BigInt.from(timestamp.millisecondsSinceEpoch ~/ 1000))))
        .toBytes();
    Uint8List serializedPreviousHash = previousHash;
    Uint8List serializedTransactionRoot = transactionRoot;
    Uint8List serializedTransactionCount =
        encodeBigInt(BigInt.from(transactionCount));
    return (BytesBuilder()
          ..add(compactSize.toSize(serializedVersion))
          ..add(serializedVersion)
          ..add(compactSize.toSize(serializedTimestamp))
          ..add(serializedTimestamp)
          ..add(compactSize.toSize(serializedPreviousHash))
          ..add(serializedPreviousHash)
          ..add(compactSize.toSize(serializedTransactionRoot))
          ..add(serializedTransactionRoot)
          ..add(compactSize.toSize(serializedTransactionCount))
          ..add(serializedTransactionCount))
        .toBytes();
  }

  @override
  String toString() => '''BlockModel
      'id': $id,
      'version': $version,
      'previousHash': $previousHash,
      'transactionRoot': $transactionRoot,
      'transactionCount': $transactionCount,
      'timestamp': $timestamp
    ''';
}
