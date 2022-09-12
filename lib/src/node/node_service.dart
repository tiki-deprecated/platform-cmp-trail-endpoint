import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/retry.dart';
import 'package:sqlite3/sqlite3.dart';
import '../utils/merkel_tree.dart';

import '../utils/rsa/rsa_public_key.dart';
import 'block/block_model.dart';
import 'keys/keys_interface.dart';
import 'keys/keys_model.dart';
import 'transaction/transaction_model.dart';

import 'backup/backup_service.dart';
import 'block/block_service.dart';
import 'keys/keys_service.dart';
import 'transaction/transaction_service.dart';
import 'wasabi/wasabi_service.dart';

/// The node slice is responsible for orchestrating the other slices to keep the
/// blockchain locally, persist blocks and syncing with remote backup and other
/// blockchains in the network.
class NodeService {
  static const scheme = "tiki://";

  late final BackupService _backupService;
  late final BlockService _blockService;
  late final KeysService _keysService;
  late final TransactionService _transactionService;
  late final WasabiService _wasabiService;
  // late final XchainService _xchainService;
  late final KeysModel _keys;

  Timer? _blkTimer;
  late final Duration _blkInterval;

  CryptoRSAPublicKey get publicKey => _keys.privateKey.public;

  /// Initialzes de servic.e
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
  /// The [keysSecureStorage] should be a [KeysSecureStorageInterface] implementation
  /// using encrypted key-value storage, specifically for each host OS.
  /// It should not be accessed by other applications or users because it will
  /// store the private keys of the user, which is required for write operations
  /// in the chain.
  ///
  /// EncryptedSharedPreferences should be used for Android. AES encryption is
  /// another option with AES secret key encrypted with RSA and RSA key is stored
  /// in KeyStore.
  ///
  /// Keychain is recommended for iOS and MacOS.
  ///
  /// For Linux libscret is a reliable option.
  ///
  /// In JavaScript web environments the recommendation is WebCrypto with HTST enabled.
  ///
  /// In other enviroments, use equivalent implementations of the recommended ones.
  ///
  /// The [NodeService] uses a internal [Timer] to build a new [BlockModel] every
  /// [blkInterval]. The default value is 1 minute. If there are any [TransactionModel]
  /// in the [database] that was not added to a [BlockModel] yet, it creates a new
  /// [BlockModel] if the last [TransactionModel] was created before 1 minute ago
  /// or if the total size of the serialized transactions is greater than 100kb.
  Future<NodeService> init(
      {required String apiKey,
      required Database database,
      required KeysInterface keysSecureStorage,
      List<String> adresses = const [],
      blkInterval = const Duration(minutes: 1)}) async {
    _blkInterval = blkInterval;
    _keysService = KeysService(keysSecureStorage);
    _transactionService = TransactionService(database);
    _blockService = BlockService(database);

    await _loadKeys(adresses);

    _wasabiService = WasabiService(apiKey, _keys.privateKey);
    _backupService = BackupService(base64.encode(_keys.address), _keysService,
        _blockService, _transactionService, _wasabiService, database);

    _backupService.write('pubKey');

    await _createBlock();

    _setBlkTimer();

    return this;
  }

  /// Creates a [TransactionModel] with the [contents] and save to local [database].
  ///
  /// When a [TransactionModel] is created it is not added to the next block
  /// immediately. It needs to wait until the [_blkTimer] runs again to check if
  /// the oldest transaction was created more than [_blkInterval] duration or
  /// if the [TransactionModel] waiting to be added in a [BlockModel] already
  /// reached 100Kb in size.
  TransactionModel write(Uint8List contents) {
    TransactionModel txn =
        _transactionService.create(keys: _keys, contents: contents);
    _createBlock();
    return txn;
  }

  TransactionModel? getTransactionById(String id) =>
      _transactionService.getById(id);

  List<TransactionModel> getTransactionsByBlockId(String blockId) =>
      _transactionService.getByBlock(base64.decode(blockId));

  BlockModel? getLastBlock() => _blockService.getLast();

  Future<void> _createBlock() async {
    List<TransactionModel> txns = _transactionService.getPending();
    if (txns.isNotEmpty) {
      DateTime lastCreated = txns.last.timestamp;
      DateTime oneMinAgo = DateTime.now().subtract(_blkInterval);
      if (lastCreated.isBefore(oneMinAgo) || txns.length >= 200) {
        List<Uint8List> hashes = txns.map((e) => e.id!).toList();
        MerkelTree merkelTree = MerkelTree.build(hashes);
        Uint8List transactionRoot = merkelTree.root!;
        BlockModel blk = _blockService.create(txns, transactionRoot);
        for (TransactionModel transaction in txns) {
          transaction.block = blk;
          transaction.merkelProof = merkelTree.proofs[transaction.id];
          _transactionService.commit(transaction);
        }
        _blockService.commit(blk);
        _backupService.write(base64.encode(blk.id!));
      }
      if (_blkTimer == null || !_blkTimer!.isActive) _setBlkTimer();
    }
  }

  Future<void> _loadKeys(List<String> adresses) async {
    for (String address in adresses) {
      KeysModel? keys = await _keysService.get(address);
      if (keys != null) {
        _keys = keys;
        return;
      }
    }

    _keys = await _keysService.create();
  }

  void _setBlkTimer() {
    _blkTimer = Timer.periodic(_blkInterval, (_) => _createBlock());
  }
}
