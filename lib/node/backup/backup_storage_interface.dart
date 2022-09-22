import 'dart:typed_data';

abstract class BackupStorageInterface {
  Future<void> write(String path, Uint8List obj);
  Future<Uint8List?> read(String path);
}
