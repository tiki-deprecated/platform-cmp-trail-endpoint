import 'dart:typed_data';

import '../../utils/rsa/rsa.dart';
import '../../utils/rsa/rsa_private_key.dart';
import 'backup_repository.dart';

class BackupModel {
  int? id;
  final String assetRef;
  String? payload;
  late final Uint8List signature;
  DateTime? timestamp;

  BackupModel(
      {required this.assetRef,
      required this.payload,
      required CryptoRSAPrivateKey signKey}) {
    signature = sign(signKey,
        Uint8List.fromList([...assetRef.codeUnits, ...payload!.codeUnits]));
  }

  BackupModel.fromMap(Map<String, dynamic> map)
      : id = map[BackupRepository.collumnId],
        assetRef = map[BackupRepository.collumnAssetRef],
        payload = map[BackupRepository.collumnPayload],
        signature = map[BackupRepository.collumnSignature],
        timestamp = map[BackupRepository.collumnTimestamp] == null ? null :
          DateTime.fromMillisecondsSinceEpoch(
            map[BackupRepository.collumnTimestamp] * 1000);

  @override
  String toString() {
    return '''BackupModel
      id : $id
      assetRef : $assetRef
      payload : $payload
      signature : $signature
      timestamp : $timestamp
    ''';
  }
}
