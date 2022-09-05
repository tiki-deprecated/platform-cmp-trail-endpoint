import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:sqlite3/sqlite3.dart';
import '../utils/json_object.dart';
import '../utils/merkel_tree.dart';
import '../utils/page_model.dart';
import '../utils/rsa/rsa_public_key.dart';
import '../utils/utils.dart';
import 'block/block_model.dart';
import 'block/block_model_reponse.dart';
import 'keys/keys_model.dart';
import 'transaction/transaction_model.dart';

import 'backup/backup_service.dart';
import 'block/block_service.dart';
import 'keys/keys_secure_storage_interface.dart';
import 'keys/keys_service.dart';
import 'transaction/transaction_service.dart';
import 'wasabi/wasabi_model.dart';
import 'wasabi/wasabi_service.dart';
import 'xchain/xchain_model.dart';
import 'xchain/xchain_service.dart';

/// The node slice is responsible for orchestrating the other slices to keep the
/// blockchain locally, persist blocks and syncing with remote backup and other
/// blockchains in the network.
class NodeService {
  late final BackupService _backupService;
  late final BlockService _blockService;
  late final KeysService _keysService;
  late final TransactionService _transactionService;
  late final WasabiService _wasabiService;
  late final XchainService _xchainService;
  late final KeysModel _keys;

  Timer? _blkTimer;
  Duration? _blkInterval;

  CryptoRSAPublicKey get publicKey => _keys.privateKey.public;
  String get address => base64Url.encode(sha256(base64Url.decode(publicKey.encode())));

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
      List<String> adresses = const [],
      required Database database,
      KeysSecureStorageInterface? keysSecureStorage,
      Duration? blkInterval}) async {
    _wasabiService = WasabiService(apiKey);
    _backupService = BackupService(database, _wasabiService);
    _blockService = BlockService(database);
    _keysService = KeysService(keysSecureStorage, _backupService);
    _transactionService = TransactionService(database);

    _xchainService = XchainService(database);
    _blkInterval = blkInterval ?? const Duration(minutes: 1);

    await _loadKeys(adresses);

    await _loadXchains(adresses);

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

  /// Gets a [TransactionModel] by [TransactionModel.id]
  TransactionModel? getTxn(String id) {
    return _transactionService.getById(id);
  }

  /// Removes the [TransactionModel] from local [database]
  void discardTransaction(TransactionModel txn) =>
      _transactionService.discard(txn.id!);

  /// Removes the [BlockModel] from local [database] and its [TransactionModel]
  void discardBlock(BlockModel blk, {keepTxn = false}) {
    if (!keepTxn) {
      List<TransactionModel> txns = _transactionService.getByBlock(blk.id!);
      for (TransactionModel txn in txns) {
        _transactionService.discard(txn.id!);
      }
    }
    _blockService.discard(blk);
  }

  Future<void> _createBlock() async {
    List<TransactionModel> txns = _transactionService.getNoBlock();
    if (txns.isNotEmpty) {
      int totalSize = 0;
      for (TransactionModel txn in txns) {
        totalSize += txn.serialize().buffer.lengthInBytes;
      }
      DateTime lastCreated = txns.last.timestamp;
      DateTime oneMinAgo = DateTime.now().subtract(_blkInterval!);
      if (lastCreated.isBefore(oneMinAgo) || totalSize >= 100000) {
        BlockModelResponse blkRsp = _blockService.create(txns);
        MerkelTree merkelTree = blkRsp.merkelTree;
        for (TransactionModel txn in txns) {
          txn.merkelProof = merkelTree.proofs[txn.id!];
          txn.block = blkRsp.block;
          _transactionService.update(txn, _keys);
          _backupService.write(txn.uri, JsonObject.fromMap(txn.toMap()));
        }
        _backupService.write(
            blkRsp.block.uri, JsonObject.fromMap(blkRsp.block.toMap()));
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

  Future<void> _loadXchains(List<String> addresses) async {
    for (String address in addresses) {
      String assetRef = 'tiki://$address';
      JsonObject? xchainJson = await _backupService.read(assetRef);
      if (xchainJson != null) {
        XchainModel xchain = XchainModel.fromMap(xchainJson.data);
        _xchainService.add(xchain);
      }
    }
  }

  void _setBlkTimer() {
    _blkTimer = Timer.periodic(_blkInterval!, (_) => _createBlock());
  }
}
