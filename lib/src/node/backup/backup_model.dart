
/// The model for blocks backed up in the object storage.
class BackupModel {
  String? id;
  String? signature;
  DateTime timestamp = DateTime(0);
  String? assetRef;

  BackupModel({
    this.id,
    required this.signature,
    required this.timestamp,
    required this.assetRef,
  });

  BackupModel.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        signature = map['signature'],
        timestamp =
            DateTime.fromMillisecondsSinceEpoch(map['timestamp'] * 1000),
        assetRef = map['asset_ref'];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'signature': signature,
      'timestamp': timestamp,
      'aset_ref': assetRef,
    };
  }

  @override
  String toString() {
    return '''BackupModel
      'id' : $id,
      'signature' : $signature,
      'timestamp' : $timestamp,
      'asset_ref' : $assetRef
    ''';
  }
}
