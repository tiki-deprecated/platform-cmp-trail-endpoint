import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';

import '../../utils/bytes.dart';
import 'backup_repository.dart';
import 'backup_model_asset_enum.dart';

class BackupModel {
  late final BackupModelAssetEnum assetType;
  late final String assetId;
  Uint8List? signature;
  Uint8List? payload;
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

  BackupModel.fromSerialized(Uint8List serialized) {
    List<Uint8List> extractedBytes = extractSerializeBytes(serialized);
    assetType = _assetTypeFromByte(extractedBytes[0][0]);
    assetId = base64.encode(extractedBytes[1]);
    signature = extractedBytes[2];
    payload = extractedBytes[3];
    timestamp = DateTime.fromMillisecondsSinceEpoch(
      decodeBigInt(extractedBytes[4]).toInt() * 1000);
  }
  
  Uint8List serialize() {
    BytesBuilder bytes = BytesBuilder();
    bytes.add(compactSize(Uint8List.fromList([assetType.byte])));
    bytes.addByte(assetType.byte);
    bytes.add(compactSize(base64.decode(assetId)));
    bytes.add(assetId.codeUnits);
    bytes.add(compactSize(signature!));
    bytes.add(signature!);
    bytes.add(compactSize(payload!));
    bytes.add(payload!);
    Uint8List timestampInSecs =
        encodeBigInt(BigInt.from(timestamp!.millisecondsSinceEpoch ~/ 1000));
    bytes.add(compactSize(timestampInSecs));
    bytes.add(timestampInSecs);
    return bytes.toBytes();
  }

  static BackupModelAssetEnum _assetTypeFromValue(String value) {
    switch (value) {
      case 'block':
        return BackupModelAssetEnum.block;
      case 'pubkey':
        return BackupModelAssetEnum.pubkey;
    }
    throw ArgumentError.value(value, 'Invalid asset type value.');
  }

  static BackupModelAssetEnum _assetTypeFromByte(int byte) {
    switch (byte) {
      case 0:
        return BackupModelAssetEnum.pubkey;
      case 1:
        return BackupModelAssetEnum.block;
    }
    throw ArgumentError.value(byte, 'Invalid asset type byte.');
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
