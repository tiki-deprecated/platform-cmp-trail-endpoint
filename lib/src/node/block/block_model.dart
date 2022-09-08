import 'dart:convert';
import 'dart:typed_data';

class BlockModel {
  int? seq;
  Uint8List? id;
  int version;
  Uint8List previousHash;
  Uint8List transactionRoot;
  int transactionCount;
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
      : seq = map['seq'],
        id = map['id'],
        version = map['version'],
        previousHash = map['previous_hash'],
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
      'transactionRoot': $transactionRoot,
      'transactionCount': $transactionCount,
      'timestamp': $timestamp
    ''';
  }
}
