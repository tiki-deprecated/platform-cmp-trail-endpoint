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
import 'backup/backup_service.dart';
import 'block/block_model.dart';
import 'block/block_service.dart';
import 'key/key_service.dart';
import 'transaction/transaction_service.dart';
import 'wasabi/wasabi_service.dart';

export './backup/backup_service.dart';
export './block/block_service.dart';
export './key/key_service.dart';
export './l0_storage/l0_storage_service.dart';
export './transaction/transaction_service.dart';
export './wasabi/wasabi_service.dart';
export './xchain/xchain_service.dart';

/// The node slice is responsible for orchestrating the other slices to keep the
/// blockchain locally, persist blocks and syncing with remote backup and other
/// blockchains in the network.
class NodeService {
  late final TransactionService _transactionService;
  late final BlockService _blockService;
  late final KeyService _keyService;
  late final WasabiService _wasabiService;
  late final KeyModel _primaryKey;
  late final BackupService _backupService;
  late final Duration _blockInterval;
  late final int _maxTransactions;

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
  Future<NodeService> init(
      String apiId, Database database, KeyInterface keysInterface,
      {String? primary,
      List<String> readOnly = const [],
      int maxTransactions = 200,
      Duration blockInterval = const Duration(minutes: 1)}) async {
    _transactionService = TransactionService(database);
    _blockService = BlockService(database);
    _wasabiService = WasabiService();
    _keyService = KeyService(keysInterface);
    _blockInterval = blockInterval;
    _maxTransactions = maxTransactions;

    await _loadPrimaryKey(primary);

    _backupService =
        BackupService(_wasabiService, database, apiId, _primaryKey, (id) {
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
    bytes.add(UtilsBytes.encodeBigInt(BigInt.from(transactions.length)));
    for (TransactionModel transaction in transactions) {
      bytes.add(UtilsCompactSize.encode(transaction.serialize()));
    }
    return bytes.toBytes();
  }
}
