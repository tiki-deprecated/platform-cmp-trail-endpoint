import 'dart:typed_data';

/// The remote backup key-value storage interface.
///
/// This is used by [BackupService] as storage. The implementation SHOULD be
/// responsible for authorization and access control, since Backup Service does
/// not handle those.
abstract class BackupStorageInterface {
  /// Writes a byte array [obj] in storage using the [path] as key.
  Future<void> write(String path, Uint8List obj);

  /// Reads a byte array from, storage using the [path] as key.
  Future<Uint8List> read(String path);
}
