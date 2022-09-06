import 'dart:convert';
import 'dart:typed_data';

import '../../utils/bytes.dart';
import '../xchain/xchain_model.dart';

class BlockModel {
  int? seq;
  Uint8List? id;
  int version;
  Uint8List previousHash;
  XchainModel? xchain;
  Uint8List transactionRoot;
  int transactionCount;
  late final DateTime timestamp;

  BlockModel({
    this.version = 1,
    this.xchain,
    required this.previousHash,
    required this.transactionRoot,
    required this.transactionCount,
    timestamp,
  }) {
    this.timestamp = timestamp ?? DateTime.now();
  }

  Uint8List header() {
    Uint8List serializedVersion = (BytesBuilder()
          ..add([encodeBigInt(BigInt.from(version)).length])
          ..add(encodeBigInt(BigInt.from(version))))
        .toBytes();
    Uint8List serializedTimestamp = (BytesBuilder()
          ..add([
            encodeBigInt(BigInt.from(timestamp.millisecondsSinceEpoch ~/ 1000))
                .length
          ])
          ..add(encodeBigInt(
              BigInt.from(timestamp.millisecondsSinceEpoch ~/ 1000))))
        .toBytes();
    Uint8List serializedPreviousHash = previousHash;
    Uint8List serializedTransactionRoot = transactionRoot;
    return Uint8List.fromList([
      ...serializedVersion,
      ...serializedTimestamp,
      ...serializedPreviousHash,
      ...serializedTransactionRoot
    ]);
  }

  BlockModel.fromMap(Map<String, dynamic> map)
      : seq = map['seq'],
        id = map['id'],
        version = map['version'],
        previousHash = map['previous_hash'],
        xchain = map['xchain'],
        transactionRoot = map['transaction_root'],
        transactionCount = map['transaction_count'],
        timestamp =
            DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ~/ 1000);

  static BlockModel fromJson(String jsonString) =>
      BlockModel.fromMap(jsonDecode(jsonString));

  String toJson() {
    return jsonEncode({
      'id': id,
      'version': version,
      'previous_hash': previousHash,
      'xchain': xchain,
      'transaction_root': transactionRoot,
      'transaction_count': transactionCount,
      'timestamp': timestamp.millisecondsSinceEpoch
    });
  }

  @override
  String toString() {
    return '''BlockModel
      'id': $id,
      'version': $version,
      'previousHash': $previousHash,
      'xchain': $xchain,
      'transactionRoot': $transactionRoot,
      'transactionCount': $transactionCount,
      'timestamp': $timestamp
    ''';
  }
}
