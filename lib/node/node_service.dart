/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */
library node;

import 'dart:async';

import 'dart:convert';
import 'dart:typed_data';

import 'package:sqlite3/sqlite3.dart';
import '../utils/utils.dart';

import 'backup/backup_blk_obj.dart';
import 'backup/backup_service.dart';
import 'block/block_service.dart';
import 'keys/keys_service.dart';
import 'transaction/transaction_service.dart';
import 'wasabi/wasabi_service.dart';
import 'xchain/xchain_service.dart';

export './backup/backup_service.dart';
export './block/block_service.dart';
export './keys/keys_service.dart';
export './l0_storage/l0_storage_service.dart';
export './transaction/transaction_service.dart';
export './wasabi/wasabi_service.dart';
export './xchain/xchain_service.dart';

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
  late final KeysModel _keys;
  late final XchainService _xchainService;

  Timer? _blkTimer;
  late final Duration _blkInterval;

  CryptoRSAPublicKey get publicKey => _keys.privateKey.public;

  /// Initialzes de service
  ///
  /// All the related chains addresses should be addded to [addresses] list as
  /// [base64Url] representation of the adress.
  ///
  /// The first address in the [addresses] list for which [keysInterface] has a private
  /// key is the one that will be used for read and write operations.
  /// All the other ones are used in read-only mode, even if [keysInterface]
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
  /// The [keysInterface] should be a [KeysInterface] implementation
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
      required KeysInterface keysInterface,
      List<String> addresses = const [],
      blkInterval = const Duration(minutes: 1)}) async {
    _blkInterval = blkInterval;
    _keysService = KeysService(keysInterface);
    _transactionService = TransactionService(database);
    _blockService = BlockService(database);

    await _loadKeysAndChains(addresses);

    _wasabiService = WasabiService(apiKey, _keys.privateKey);
    _backupService = BackupService(base64.encode(_keys.address), _keysService,
        _blockService, _transactionService, _wasabiService, database);

    await _backupService.write('public.key');

    await _createBlock();

    _setBlkTimer();

    return this;
  }

  /// Creates a [TransactionModel] with the [contents] and save to local [database].
  ///
  /// When a [TransactionModel] is created it is not added to the next block
  /// immediately. It needs to wait until the [_blkTimer] runs again to check if
  /// the oldest transaction was created more than [_blkInterval] duration or
  /// if there are more than 200 [TransactionModel] waiting to be added to a
  /// [BlockModel].
  TransactionModel write(Uint8List contents) {
    TransactionModel txn =
        _transactionService.build(keys: _keys, contents: contents);
    _createBlock();
    return txn;
  }

  List<TransactionModel> getTransactionsByBlockId(String blockId) =>
      _transactionService.getByBlock(base64.decode(blockId));

  BlockModel? getLastBlock() => _blockService.getLast();

  Future<BlockModel?> getBlockById(String blockId,
      {String? xchainAddress}) async {
    BlockModel? block =
        _blockService.get(blockId, xchainAddress: xchainAddress);
    if (xchainAddress == null) return block;
    if (block == null) {
      await _syncChain(xchainAddress);
    }
    return _blockService.get(blockId, xchainAddress: xchainAddress);
  }

  Future<BlockModel?> getBlockByPath(String path) async {
    Uint8List pathBytes = base64.decode(path);
    Uint8List address = pathBytes.sublist(0, 33);
    String blkId = base64.encode(pathBytes.sublist(33));
    String? xchainAddress = UtilsBytes.memEquals(address, _keys.address)
        ? null
        : base64.encode(address);
    return getBlockById(blkId, xchainAddress: xchainAddress);
  }

  Future<void> _createBlock() async {
    List<TransactionModel> txns = _transactionService.getPending();
    if (txns.isNotEmpty) {
      DateTime lastCreated = txns.last.timestamp;
      DateTime oneMinAgo = DateTime.now().subtract(_blkInterval);
      if (lastCreated.isBefore(oneMinAgo) || txns.length >= 200) {
        List<Uint8List> hashes = txns.map((e) => e.id!).toList();
        MerkelTree merkelTree = MerkelTree.build(hashes);
        Uint8List transactionRoot = merkelTree.root!;
        BlockModel blk = _blockService.build(txns, transactionRoot);
        for (TransactionModel transaction in txns) {
          transaction.block = blk;
          transaction.merkelProof = merkelTree.proofs[transaction.id];
          _transactionService.commit(transaction);
        }
        _blockService.commit(blk);
        await _backupService.write(base64Url.encode(blk.id!));
      }
      if (_blkTimer == null || !_blkTimer!.isActive) _setBlkTimer();
    }
  }

  Future<void> _loadKeysAndChains(List<String> addresses) async {
    for (String address in addresses) {
      KeysModel? keys = await _keysService.get(address);
      if (keys != null) {
        _keys = keys;
      } else {
        _loadChain(address);
      }
    }
    _keys = await _keysService.create();
  }

  Future<void> _loadChain(String address) async {
    XchainModel? xchain = _xchainService.get(address);
    if (xchain == null) {
      Uint8List publicKey = await _wasabiService.read('$address.publicKey');
      xchain = _xchainService.add(base64.encode(publicKey));
    }
    await _syncChain(xchain.address);
  }

  Future<void> _syncChain(String xchainAddress) async {
    XchainModel xchain = _xchainService.get(xchainAddress)!;
    String? bkpPath = _wasabiService.getLastPath(xchainAddress);
    CryptoRSAPublicKey publicKey =
        CryptoRSAPublicKey.decode(base64.encode(xchain.publicKey));
    while (bkpPath != null) {
      Uint8List bkpObj = await _wasabiService.read(bkpPath);
      BlockModel blk = _loadBlockBackup(bkpObj, publicKey);
      if (blk.previousHash.length == 1) {
        bkpPath = null;
      } else {
        bkpPath = "${base64Url.encode(blk.id!)}.block";
      }
    }
  }

  static bool validateBlock(
      BlockModel blk, List<TransactionModel> transactions) {
    List<Uint8List> hashes = transactions.map((e) => e.id!).toList();
    MerkelTree merkelTree = MerkelTree.build(hashes);
    Uint8List transactionRoot = merkelTree.root!;
    return UtilsBytes.memEquals(transactionRoot, blk.transactionRoot);
  }

  void _setBlkTimer() {
    _blkTimer = Timer.periodic(_blkInterval, (_) => _createBlock());
  }

  BlockModel _loadBlockBackup(Uint8List bkp, CryptoRSAPublicKey publicKey) {
    BackupBlkObj bkpObj = BackupBlkObj.deserialize(bkp);
    BlockModel blk = bkpObj.block;
    List<TransactionModel> txns = bkpObj.transactions;
    if (!validateBlock(blk, txns)) {
      throw Exception('Error in xchain sync. Invalid block ${blk.toString()}');
    }
    for (TransactionModel transaction in txns) {
      if (!TransactionService.validateIntegrity(transaction) ||
          !TransactionService.validateAuthor(transaction, publicKey) ||
          !TransactionService.validateInclusion(transaction, blk)) {
        throw Exception(
            'Error in xchain sync. Invalid transaction ${transaction.toString()}');
      }
    }
    _transactionService.addAll(txns);
    _blockService.add(blk);
    return blk;
  }
}
