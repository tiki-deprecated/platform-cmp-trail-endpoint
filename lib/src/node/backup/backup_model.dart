import '../block/block_model.dart';

/// The model for blocks backed up in the object storage.
class BackupModel {
  int? id;
  String signature;
  DateTime timestamp;
  BlockModel block;

  BackupModel({
    this.id,
    required this.signature,
    required this.timestamp,
    required this.block,
  });

  BackupModel.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        signature = map['signature'],
        timestamp =
            DateTime.fromMillisecondsSinceEpoch(map['timestamp'] * 1000),
        block = map['block'];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'signature': signature,
      'timestamp': timestamp,
      'block': block
    };
  }

  String toSqlValues() {
    return "$id, '$signature', ${timestamp.millisecondsSinceEpoch ~/ 1000}, ${block.id}";
  }

  @override
  String toString() {
    return '''BackupModel
      'id' : $id,
      'signature' : $signature,
      'timestamp' : $timestamp,
      'block' : $block
    ''';
  }
}
