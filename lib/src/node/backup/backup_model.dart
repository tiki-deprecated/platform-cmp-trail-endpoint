import 'dart:typed_data';

import 'backup_repository.dart';
import 'backup_model_asset_enum.dart';

class BackupModel {
  final BackupModelAssetEnum assetType;
  final String assetId;
  Uint8List? signature;
  List<int>? payload;
  DateTime? timestamp;

  BackupModel({
    required this.assetType,
    required this.assetId,
    required this.signature,
  });

  BackupModel.fromMap(Map<String, dynamic> map)
      : assetType = _assetTypeFromValue(map[BackupRepository.columnAssetType]),
        assetId = map[BackupRepository.columnAssetId],
        signature = map[BackupRepository.columnSignature],
        timestamp = map[BackupRepository.columnTimestamp] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(
                map[BackupRepository.columnTimestamp] * 1000);

  static BackupModelAssetEnum _assetTypeFromValue(String value) {
    switch (value) {
      case 'block':
        return BackupModelAssetEnum.block;
      case 'pubkey':
        return BackupModelAssetEnum.pubkey;
    }
    throw ArgumentError.value(value, 'Invalid asset type value.');
  }

  @override
  String toString() {
    return '''BackupModel
      assetType : ${assetType.value}
      assetId : $assetId
      timestamp : $timestamp
    ''';
  }
}
