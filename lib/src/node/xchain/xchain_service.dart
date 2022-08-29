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

  // retrieve the latest [BlockModel] that we have in database and ask for the
  // most recent ones from [WasabiService].
  void update(XchainModel chain) {
    throw UnimplementedError();
  }

  void updateAll() {
    throw UnimplementedError();
  }
}
