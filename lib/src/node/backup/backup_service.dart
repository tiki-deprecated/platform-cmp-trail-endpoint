import 'package:sqlite3/sqlite3.dart';

import 'backup_repository.dart';

class BackupService {
  final BackupRepository _repository;

  BackupService(Database db) : _repository = BackupRepository(db);

  /// Saves the [obj] remotely via [WasabiService].
  Future<void> write(Object obj) async{
    // WasabiService
    //_repository.save();
  }

}
