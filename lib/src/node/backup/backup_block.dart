import '../block/block_model.dart';

/// The model for blocks backed up in the object storage.
class BackupModel<T> {
  int? id;
  String signature;
  DateTime timestamp;
  T payload;

  BackupModel({
    this.id,
    required this.signature,
    required this.timestamp,
    required this.payload,
  });

  BackupModel.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        signature = map['signature'],
        timestamp =
            DateTime.fromMillisecondsSinceEpoch(map['timestamp'] * 1000),
        payload = map['payload'];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'signature': signature,
      'timestamp': timestamp,
      'payload': payload
    };
  }

  @override
  String toString() {
    return '''BackupModel
      'id' : $id,
      'signature' : $signature,
      'timestamp' : $timestamp,
      'payload' : $payload
    ''';
  }
}
