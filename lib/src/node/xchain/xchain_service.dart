import 'package:sqlite3/sqlite3.dart';

import 'xchain_model.dart';
import 'xchain_repository.dart';

/// Responsible for managing cross chain sync.
class XchainService {
  final XchainRepository _repository;

  XchainService(Database? db) : _repository = XchainRepository(db: db);

  void add(XchainModel chain) {
    _repository.save(chain);
    update(chain);
  }

  void update(XchainModel chain) {
    throw UnimplementedError();
  }

  void updateAll(List<String> uris) {
    throw UnimplementedError();
  }
}
