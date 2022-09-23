/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */
library node;

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';
import 'package:sqlite3/sqlite3.dart';

import '../utils/utils.dart';
import 'backup/backup_service.dart';
import 'backup/backup_storage_interface.dart';
import 'block/block_service.dart';
import 'key/key_service.dart';
import 'transaction/transaction_service.dart';
import 'xchain/xchain_service.dart';

export './backup/backup_service.dart';
export './block/block_service.dart';
export './key/key_service.dart';
export './transaction/transaction_service.dart';
export './xchain/xchain_service.dart';

/// The node slice is responsible for orchestrating the other slices to keep the
/// blockchain locally, persist blocks and syncing with remote backup and other
/// blockchains in the network.
class NodeService {
  late final TransactionService _transactionService;
  late final BlockService _blockService;
  late final KeyService _keyService;
  late final KeyModel _primaryKey;
  late final BackupService _backupService;
  late final BackupStorageInterface _backupStorage;
  late final Duration _blockInterval;
  late final int _maxTransactions;
  late final XchainService _xchainService;

  CryptoRSAPublicKey get publicKey => _primaryKey.privateKey.public;

  /// Initialize the service
  ///
  /// All the related chains addresses should be added to [addresses] list as
  /// [base64Url] representation of the address.
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
  /// For Linux libsecret is a reliable option.
  ///
  /// In JavaScript web environments the recommendation is WebCrypto with HTST enabled.
  ///
  /// In other environments, use equivalent implementations of the recommended ones.
  ///
  /// The [NodeService] uses a internal [Timer] to build a new [BlockModel] every
  /// [blkInterval]. The default value is 1 minute. If there are any [TransactionModel]
  /// in the [database] that was not added to a [BlockModel] yet, it creates a new
  /// [BlockModel] if the last [TransactionModel] was created before 1 minute ago
  /// or if the total size of the serialized transactions is greater than 100kb.
  ///
  Future<NodeService> init(Database database, KeyInterface keysInterface,
      BackupStorageInterface backupStorage,
      {String? primary,
      List<String> readOnly = const [],
      int maxTransactions = 200,
      Duration blockInterval = const Duration(minutes: 1)}) async {
    _backupStorage = backupStorage;
    _transactionService = TransactionService(database);
    _blockService = BlockService(database);
    _keyService = KeyService(keysInterface);
    _xchainService = XchainService(database, _backupStorage);
    _blockInterval = blockInterval;
    _maxTransactions = maxTransactions;

    await _loadPrimaryKey(primary);

    _backupService = BackupService(_backupStorage, database, _primaryKey, (id) {
      BlockModel? header = _blockService.get(id);
      if (header == null) return null;

      List<TransactionModel> transactions = _transactionService.getByBlock(id);
      if (transactions.isEmpty) return null;

      return _serializeBlock(header, transactions);
    });

    List<TransactionModel> transactions = _transactionService.getPending();
    if (transactions.isNotEmpty &&
        transactions.last.timestamp
            .isBefore(DateTime.now().subtract(_blockInterval))) {
      await _createBlock(transactions);
    }

    _startBlockTimer();
    return this;
  }

  /// Creates a [TransactionModel] with the [contents] and save to local [database].
  ///
  /// When a [TransactionModel] is created it is not added to the next block
  /// immediately. It needs to wait until the [_blkTimer] runs again to check if
  /// the oldest transaction was created more than [_blkInterval] duration or
  /// if there are more than 200 [TransactionModel] waiting to be added to a
  /// [BlockModel].
  Future<TransactionModel> write(Uint8List contents) async {
    TransactionModel transaction =
        _transactionService.create(contents, _primaryKey);
    List<TransactionModel> transactions = _transactionService.getPending();
    if (transactions.length >= _maxTransactions) {
      await _createBlock(transactions);
    }
    return transaction;
  }

  BlockModel? getLastBlock() => _blockService.last();

  Future<BlockModel?> getBlockById(Uint8List blockId,
      {Uint8List? xchainId}) async {
    BlockModel? block = _blockService.get(blockId, xchainAddress: xchainId);
    if (block != null || xchainId == null) return block;
    await _loadXchain(xchainId, blockId);
    block = _blockService.get(blockId, xchainAddress: xchainId);
    if (block != null) _xchainService.update(xchainId, blockId);
    return block;
  }

  Future<TransactionModel?> getTransactionByPath(String path) async {
    List<String> pathParts = path.split('/');
    Uint8List blockId = base64Url.decode(pathParts[pathParts.length - 2]);
    Uint8List xchainId = base64Url.decode(pathParts[pathParts.length - 3]);
    BlockModel? block = await getBlockById(blockId, xchainId: xchainId);
    if (block != null) {
      Uint8List transactionId = base64.decode(pathParts.removeLast());
      TransactionModel? txn =
          _transactionService.getById(transactionId);
      if (txn == null) {
        String blockPath = pathParts.join('/');
        Uint8List serializedBackup =
            await _backupStorage.read('$blockPath.block');
        List<Uint8List> backupList = UtilsCompactSize.decode(serializedBackup);
        Uint8List serializedBlock = backupList[1];
        List<TransactionModel> transactions =
            TransactionService.deserializeTransactions(serializedBlock);
        MerkelTree merkelTree = MerkelTree.build(
            transactions.map((TransactionModel txn) => txn.id!).toList());
        if (!UtilsBytes.memEquals(block.transactionRoot, merkelTree.root!)) {
          throw Exception('Invalid transaction root for ${block.toString()}');
        }
        for (TransactionModel transaction in transactions) {
          if (UtilsBytes.memEquals(transaction.id!, transactionId)) {
            transaction.block = block;
            transaction.merkelProof = merkelTree.proofs[transaction.id!];
            _transactionService.commit(transaction);
            txn = transaction;
          }
        }
      }
      return txn;
    }
    return null;
  }

  Future<void> _loadPrimaryKey(String? address) async {
    if (address != null) {
      KeyModel? key = await _keyService.get(address);
      if (key != null) {
        _primaryKey = key;
        return;
      }
    }
    _primaryKey = await _keyService.create();
  }

  void _startBlockTimer() => Timer.periodic(_blockInterval, (_) async {
        List<TransactionModel> transactions = _transactionService.getPending();
        if (transactions.isNotEmpty) {
          await _createBlock(transactions);
        }
        _startBlockTimer();
      });

  Future<void> _createBlock(List<TransactionModel> transactions) async {
    List<Uint8List> hashes = transactions.map((e) => e.id!).toList();
    MerkelTree merkelTree = MerkelTree.build(hashes);
    BlockModel header = _blockService.create(merkelTree.root!);

    for (TransactionModel transaction in transactions) {
      transaction.block = header;
      transaction.merkelProof = merkelTree.proofs[transaction.id];
      _transactionService.commit(transaction);
    }
    _blockService.commit(header);
    _backupService.block(header.id!);
  }

  Uint8List? _serializeBlock(
      BlockModel header, List<TransactionModel> transactions) {
    BytesBuilder bytes = BytesBuilder();
    bytes.add(header.serialize());
    bytes.add(TransactionService.serializeTransactions(transactions));
    return bytes.toBytes();
  }

  Future<void> _loadXchain(xchainId, startBlockId) async {
    XchainModel xchain = await _xchainService.load(xchainId);
    String path =
        '${base64UrlEncode(xchain.address)}/${base64UrlEncode(startBlockId)}.block';
    Uint8List serializedBackup = await _backupStorage.read(path);
    List<Uint8List> backupList = UtilsCompactSize.decode(serializedBackup);
    Uint8List signature = backupList[0];
    Uint8List serializedBlock = backupList[1];
    if (!UtilsRsa.verify(xchain.publicKey, serializedBlock, signature)) {
      throw StateError(
          'Backup signature could not be verified for $path');
    }
    BlockModel block = BlockModel.deserialize(serializedBlock);
    if (!UtilsBytes.memEquals(
        Digest('SHA3-256').process(block.serialize()), startBlockId)) {
      throw Exception('Corrupted Block ${block.toString()}');
    }
    List<TransactionModel> transactions =
        TransactionService.deserializeTransactions(serializedBlock);
    MerkelTree merkelTree = MerkelTree.build(
        transactions.map((TransactionModel txn) => txn.id!).toList());
    if (!UtilsBytes.memEquals(block.transactionRoot, merkelTree.root!)) {
      throw Exception('Invalid transaction root for ${block.toString()}');
    }
    for (TransactionModel transaction in transactions) {
      transaction.block = block;
      transaction.merkelProof = merkelTree.proofs[transaction.id!];
      if (!TransactionService.validateAuthor(transaction, xchain.publicKey)) {
        throw Exception(
            'Transaction authorshhip could not be verified: ${transaction.toString()}');
      }
    }
    _blockService.add(block, xchainId);
    if (UtilsBytes.memEquals(block.id!, xchain.lastBlock)) {
      _loadXchain(xchainId, block.previousHash);
    }
  }
}
