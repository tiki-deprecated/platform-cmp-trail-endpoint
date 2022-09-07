import 'dart:convert';
import 'dart:typed_data';

import 'backup_repository.dart';
import 'backup_model_asset_enum.dart';

class BackupModel {
  final BackupModelAssetEnum assetType;
  final String assetId;
  Uint8List? signature;
  Uint8List? payload;
  DateTime? timestamp;

  BackupModel({
    required this.assetType,
    required this.assetId,
  });

  BackupModel.fromMap(Map<String, dynamic> map)
      : assetType = map[BackupRepository.collumnAssetType],
        assetId = map[BackupRepository.collumnAssetId],
        signature = map[BackupRepository.collumnSignature],
        timestamp = map[BackupRepository.collumnTimestamp] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(
                map[BackupRepository.collumnTimestamp] * 1000);

  @override
  String toString() {
    return '''BackupModel
      assetType : ${assetType.value}
      assetId : $assetId
      timestamp : $timestamp
    ''';
  }
}
