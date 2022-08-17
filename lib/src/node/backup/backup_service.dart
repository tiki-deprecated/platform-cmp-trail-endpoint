import 'package:sqlite3/sqlite3.dart';

import '../block/block_model.dart';
import 'backup_model.dart';
import 'backup_repository.dart';

class BackupService {
  final BackupRepository _repository;

  BackupService(Database db) : _repository = BackupRepository(db);

  /// Saves the [block] remotely via [WasabiService].
  Future<void> backup(BlockModel block) async {}

  /// Checks if [block] was saved in remote backup.
  bool isBackupDone(BlockModel block) {
    return false;
  }
}
