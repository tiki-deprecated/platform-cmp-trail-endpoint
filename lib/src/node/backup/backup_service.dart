import 'package:sqlite3/sqlite3.dart';

import '../block/block_model.dart';
import 'backup_repository.dart';

class BackupService {
  final BackupRepository _repository;

  BackupService(Database db) : _repository = BackupRepository(db);

  /// Saves the [block] remotely via [WasabiService].
  Future<void> write(BlockModel block) async {}

}
