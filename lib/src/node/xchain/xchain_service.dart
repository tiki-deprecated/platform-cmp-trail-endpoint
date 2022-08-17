import 'package:logging/logging.dart';
import 'package:sqlite3/sqlite3.dart';

import 'xchain_model.dart';
import 'xchain_repository.dart';

/// Responsible for managing cross chain sync.
class XchainService {
  final Logger _log = Logger('XchainService');

  final XchainRepository _repository;

  XchainService(Database db) : _repository = XchainRepository(db);

  /// Retrieves all chains that were not synced since [lastChecked]
  /// and updates them with [WasabiService].
  Future<void>  syncSince(DateTime lastChecked) async {
    // _sync(chain);
  }

  /// Retrieves the [chain] from the database and updates them with [WasabiService].
  /// If the [chain] was not added, throws an error.
  Future<void>  syncChain(XchainModel chain) async {
    // _sync(chain);
  }

  /// Adds the [chain] to the database and updates it with [WasabiService].
  /// If the [chain] was already added, throws and error.
  Future<void>  add(XchainModel chain) async {
    try {
      _repository.save(chain);
      _sync(chain);
    } catch (e) {
      _log.warning('Xchain add error: ${e.toString()}');
    }
  }

  /// Syncs the [chain] by retrieving the latest [BlockModel] from [BlockService] 
  /// and ask for the most recent ones from [WasabiService].
  Future<void> _sync(XchainModel chain) async {
    // BlockService.getLastBlock()
    // WasabiService.getChain
    throw UnimplementedError();
  }
}
