/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

/// The core of the Blockchain.
library node;

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'xchain/xchain_service.dart';

import '../utils/utils.dart';
import 'backup/backup_service.dart';
import 'block/block_service.dart';
import 'key/key_service.dart';
import 'transaction/transaction_service.dart';

export './backup/backup_service.dart';
export './block/block_service.dart';
export './key/key_service.dart';
export './transaction/transaction_service.dart';
export '../shared_storage/wasabi/wasabi_service.dart';

/// The node slice is responsible for orchestrating the other slices to keep the
/// blockchain locally, persist blocks and syncing with remote backup and other
/// blockchains in the network.
class NodeService {
  late final TransactionService _transactionService;
  late final BlockService _blockService;
  late final KeyModel _primaryKey;
  late final BackupService _backupService;
  late final XchainService _xchainService;
  late final Duration _blockInterval;
  late final int _maxTransactions;

  Timer? _blockTimer;

  List<String> _readOnly = [];

  String get address => base64Url.encode(_primaryKey.address);

  set blockInterval(Duration val) => _blockInterval = val;
  set maxTransactions(int val) => _maxTransactions = val;
  set transactionService(TransactionService val) => _transactionService = val;
  set blockService(BlockService val) => _blockService = val;
  set backupService(BackupService val) => _backupService = val;
  set xchainService(XchainService val) => _xchainService = val;
  set readOnly(List<String> val) => _readOnly = val;
  set primaryKey(KeyModel val) => _primaryKey = val;

  startBlockTimer() => _blockTimer == null ? _startBlockTimer() : null;

  Future<void> init() async {
    await _loadReadOnly();
    _startBlockTimer();
  }

  /// Creates a [TransactionModel] with the [contents] and save to local database.
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

  /// Gets a serialized block by its [id].
  Uint8List? getBlock(Uint8List id) {
    BlockModel? header = _blockService.get(id);
    if (header == null) return null;

    List<TransactionModel> transactions = _transactionService.getByBlock(id);
    if (transactions.isEmpty) return null;

    return _serializeBlock(header, transactions);
  }

  void _startBlockTimer() {
    if (_blockTimer == null || !_blockTimer!.isActive) {
      _blockTimer = Timer.periodic(_blockInterval, (_) async {
        List<TransactionModel> transactions = _transactionService.getPending();
        if (transactions.isNotEmpty) {
          await _createBlock(transactions);
        }
      });
    }
  }

  Future<void> _createBlock(List<TransactionModel> transactions) async {
    List<Uint8List> hashes = transactions.map((e) => e.id!).toList();
    MerkelTree merkelTree = MerkelTree.build(hashes);
    BlockModel header = _blockService.create(merkelTree.root!);

    for (TransactionModel transaction in transactions) {
      _transactionService.commit(
          transaction.id!, header, merkelTree.proofs[transaction.id]!);
    }
    _blockService.commit(header);
    _backupService.block(header.id!);
  }

  Uint8List? _serializeBlock(
      BlockModel header, List<TransactionModel> transactions) {
    BytesBuilder bytes = BytesBuilder();
    bytes.add(header.serialize());
    bytes.add(CompactSize.encode(
        Bytes.encodeBigInt(BigInt.from(transactions.length))));
    for (TransactionModel transaction in transactions) {
      bytes.add(CompactSize.encode(transaction.serialize()));
    }
    return bytes.toBytes();
  }

  Future<void> _loadReadOnly() async {
    List<Future> loads = [];
    for (String address in _readOnly) {
      XchainModel? xchain =
          await _xchainService.loadKey(base64Url.decode(address));
      List<String> cachedBlocks = _blockService.getCachedIds(xchain.address);
      loads.add(
          _xchainService.loadXchain(xchain, skip: cachedBlocks).then((blocks) {
        for (BlockModel block in blocks.keys) {
          List<TransactionModel> txns = blocks[block]!;
          for (TransactionModel txn in txns) {
            _transactionService.add(txn);
          }
          _blockService.commit(block, xchain: base64Url.decode(address));
        }
      }));
    }
    await Future.wait(loads);
  }
}
