import 'dart:typed_data';

import '../../utils/utils.dart';
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
    this.seq,
    this.version = 1,
    this.xchain,
    required this.previousHash,
    required this.transactionRoot,
    required this.transactionCount,
    timestamp,
  }) {
    this.timestamp = timestamp ?? DateTime.now();
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'version': version,
      'previous_hash': previousHash,
      'xchain': xchain?.toMap(),
      'transaction_root': transactionRoot,
      'transaction_count': transactionCount,
      'timestamp': timestamp.millisecondsSinceEpoch
    };
  }

  Uint8List header() {
    Uint8List serializedVersion = serializeInt(version);
    Uint8List serializedTimestamp =
        serializeInt(timestamp.millisecondsSinceEpoch ~/ 1000);
    Uint8List serializedPreviousHash = previousHash;
    Uint8List serializedTransactionRoot = transactionRoot;
    return Uint8List.fromList([
      ...serializedVersion,
      ...serializedTimestamp,
      ...serializedPreviousHash,
      ...serializedTransactionRoot
    ]);
  }

  @override
  String toString() {
    return '''BlockModel
      'id': $id,
      'version': $version,
      'previousHash': $previousHash,
      'xchain': ${xchain.toString()},
      'transactionRoot': $transactionRoot,
      'transactionCount': $transactionCount,
      'timestamp': $timestamp
    ''';
  }
}
