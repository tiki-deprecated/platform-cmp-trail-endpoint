import 'dart:typed_data';
import 'backup_repository.dart';

class BackupModel {
  late final String path;
  Uint8List? signature;
  DateTime? timestamp;

  BackupModel({
    required this.path,
    this.signature,
    this.timestamp
  });

  BackupModel.fromMap(Map<String, dynamic> map)
      : path = map[BackupRepository.columnPath],
        signature = map[BackupRepository.columnSignature],
        timestamp = map[BackupRepository.columnTimestamp] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(
                map[BackupRepository.columnTimestamp] * 1000);

  @override
  String toString() {
    return '''BackupModel
      path : $path,
      signature : $signature,
      timestamp : $timestamp
    ''';
  }
}
