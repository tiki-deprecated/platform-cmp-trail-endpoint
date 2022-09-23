import 'dart:typed_data';

import 'package:tiki_sdk_dart/node/backup/backup_storage_interface.dart';

class InMemBackup implements BackupStorageInterface {
  Map<String, Uint8List> storage = {};

  @override
  Future<Uint8List> read(String path) async {
    Uint8List value = storage[path]!;
    return value;
  }

  @override
  Future<void> write(String path, Uint8List obj) async {
    storage[path] = obj;
  }
}
