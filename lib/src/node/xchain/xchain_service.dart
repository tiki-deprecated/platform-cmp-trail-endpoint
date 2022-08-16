import 'package:logging/logging.dart';
import 'package:sqlite3/sqlite3.dart';

import 'xchain_model.dart';
import 'xchain_repository.dart';

/// Responsible for managing cross chain sync.
class XchainService {
  final Logger _log = Logger('XchainService');

  final XchainRepository _repository;

  XchainService(Database db) : _repository = XchainRepository(db);

  void syncSince(DateTime lastChecked) {
    // retrieve all chains that were not synced since lastChecked
    // and loop through
    // _sync(chain);
  }

  void syncChain(XchainModel xchain) {
    // retrieve the chain from the database and sync it
    // if the chain was not added, throw an error
    // _sync(chain);
  }

  void add(XchainModel chain) {
    try {
      _repository.save(chain);
    } catch (e) {
      _log.warning('Xchain add error: ${e.toString()}');
    }
  }

  // retrieve the latest [BlockModel] that we have in database and ask for the
  // most recent ones from [BackupService].
  void _sync(XchainModel chain) {
    throw UnimplementedError();
  }
}
