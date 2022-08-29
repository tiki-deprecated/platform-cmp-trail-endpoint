import 'package:sqlite3/sqlite3.dart';

import 'backup_repository.dart';

class BackupService {
  final BackupRepository _repository;

  BackupService(Database? db) : _repository = BackupRepository(db);

  /// Saves the [obj] remotely via [WasabiService].
  Future<void> _write(String id, Object obj) async {
    // WasabiService
    //_repository.save();
  }

  /// Reads the [obj] remotely via [WasabiService].
  Future<void> _read(String id, Object obj) async {
    // WasabiService
    //_repository.save();
  }

  /// Saves the [obj] remotely via [WasabiService].
  Future<void> writeBlock(Object obj) async {
    // WasabiService
    //_repository.save();
  }

  // readBlock

  // writeBlock

  // readPubKey

  // writePubKey
}
