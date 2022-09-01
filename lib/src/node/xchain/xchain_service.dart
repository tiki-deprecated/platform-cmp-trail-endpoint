import 'package:sqlite3/sqlite3.dart';

import '../../utils/json_object.dart';
import '../backup/backup_service.dart';
import '../block/block_model.dart';
import '../block/block_service.dart';
import '../wasabi/wasabi_service.dart';
import 'xchain_model.dart';
import 'xchain_repository.dart';

/// Responsible for managing cross chain sync.
class XchainService {
  final XchainRepository _repository;

  XchainService(Database? db) : _repository = XchainRepository(db: db);

  void add(XchainModel chain) {
    _repository.save(chain);
  }
}
