import 'package:logging/logging.dart';
import 'package:sqlite3/sqlite3.dart';

import 'xchain_model.dart';
import 'xchain_repository.dart';

/// Responsible for managing cross chain sync.
class XchainService {
  final Logger _log = Logger('XchainService');

  final XchainRepository _repository;

  XchainService(Database db) : _repository = XchainRepository(db);

  void add(XchainModel chain) {
    try {
      _repository.save(chain);
      update(chain);
    } catch (e) {
      _log.warning('Xchain add error: ${e.toString()}');
    }
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
