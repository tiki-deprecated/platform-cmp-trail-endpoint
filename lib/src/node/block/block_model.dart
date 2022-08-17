import 'package:logging/logging.dart';

import '../xchain/xchain_model.dart';

class BlockModel {

  int? blockId;
  int version;
  String previousHash;
  XchainModel xchain;
  String transactionRoot;
  int transactionCount;
  DateTime timestamp;

  BlockModel({
    this.blockId,
    this.version = 1,
    required this.previousHash,
    required this.xchain,
    required this.transactionRoot,
    required this.transactionCount,
    required this.timestamp,
  });

  BlockModel.fromMap(Map<String, dynamic> map)
      : blockId = map['block_id'],
        version = map['version'],
        previousHash = map['previous_hash'],
        xchain = XchainModel.fromMap(map['xchain']),
        transactionRoot = map['transaction_root'],
        transactionCount = map['transaction_count'],
        timestamp =
            DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ~/ 1000);

  Map<String, dynamic> toMap() {
    return {
      'blockId': blockId,
      'version': version,
      'previousHash': previousHash,
      'xchain': xchain.toMap(),
      'transactionRoot': transactionRoot,
      'transactionCount': transactionCount,
      'timestamp': timestamp.millisecondsSinceEpoch
    };
  }

  String toSqlValues() {
    return '''$blockId, $version, '$previousHash', ${xchain.xchainId},
      '$transactionRoot', $transactionCount, $timestamp''';
  }

  @override
  String toString() {
    return '''BlockModel
      'blockId': $blockId,
      'version': $version,
      'previousHash': $previousHash,
      'xchain': ${xchain.toString()},
      'transactionRoot': $transactionRoot,
      'transactionCount': $transactionCount,
      'timestamp': ${timestamp.millisecondsSinceEpoch}
    ''';
  }
}
