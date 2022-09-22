import 'dart:typed_data';

import 'package:tiki_sdk_dart/node/backup/backup_storage_interface.dart';

Map<String, Uint8List> storage = {};

class InMemBackup implements BackupStorageInterface {
  @override
  Future<Uint8List?> read(String path) async => storage[path];

  @override
  Future<void> write(String path, Uint8List obj) async => storage[path] = obj;
}
