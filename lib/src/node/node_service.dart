import 'dart:typed_data';

import 'package:sqlite3/sqlite3.dart';

import 'backup/backup_service.dart';
import 'block/block_service.dart';
import 'bouncer/bouncer_service.dart';
import 'keys/keys_secure_storage_interface.dart';
import 'keys/keys_service.dart';
import 'transaction/transaction_service.dart';
import 'wasabi/wasabi_service.dart';
import 'xchain/xchain_service.dart';

///The node slice is responsible for orchestrating the other slices to keep the
///blockchain locally, persist blocks and syncing with remote backup and other
/// blockchains in the network.
class NodeService {
  late final BackupService _backupService;
  late final BlockService _blockService;
  late final BouncerService _bouncerService;
  late final KeysService _keysService;
  late final TransactionService _transactionService;
  late final WasabiService _wasabiService;
  late final XchainService _xchainService;

  late final String _address;

  /// Initialzes de service.
  /// 
  /// Upon initialization, loops through [addresses] to load the corresponding
  /// [Xchain] from remote backup and syncrhorize with local [database]. 
  ///
  /// The first address in the list for which [keysSecureStorage] has a private 
  /// key is the one that will be used for read and write operations. 
  /// All the other ones are used in read-only mode, even if [keysSecureStorage] 
  /// has its private key stored.
  /// 
  /// The [apiKey] is used for remote backup connection. Please visit mytiki.com
  /// to get yours. If no [apiKey] is provided or if the key is invalid, the node
  /// will work in local mode only and will be not able to save the chain remotely
  /// nor synchronize with other chains.
  /// 
  /// The [database] should be a [Database] instance, implemented in the host OS
  /// appropriate library. If no [database] is provided the SDK will use the OS
  /// memory for persistence what could cause inconsistencies. It should only be 
  /// used for tests or thin clients with read-only operations. It is NOT RECOMMENDED 
  /// for writing to the chain. 
  /// 
  /// The [keysSecureStorage] should be a SECURE STORAGE implementation, specifically
  /// for each host OS. It should not be accessed by other applications or users
  /// because it will store the private keys of the user, which is required for write
  /// operations in the chain.
  /// 
  /// In Android the recommendation is
  /// In iOS the recommendation is
  /// In JavaScript web environments the recommendation is
  /// In other enviroments, use equivalent implementations of the recommended ones.
  NodeService init( 
      {String? apiKey,
      List<String> adresses = const [],
      Database? database,
      KeysSecureStorageInterface? keysSecureStorage}) async 
  {
    _backupService = BackupService(database);
    _blockService = BlockService(database);
    _bouncerService = BouncerService();
    _keysService = KeysService(KeysSecureStorage);
    _transactionService = TransactionService(_keysService, database);
    _wasabiService = WasabiService();
    _xchainService = XchainService(database);

    _loadKeys(adresses);

    _loadXchains(adresses);

    return this;
  }

  /// Writes [contents] to a transaction.
  String write(Uint8List contents, String assetRef) {
    throw UnimplementedError();
  }

  /// Reads the [TransactionModel] from its [id].
  Uint8List(String id) {
    throw UnimplementedError();
  }

  void _loadKeys(List<String> adresses) {}

  void _loadXchains(List<String> adresses) {}
}
