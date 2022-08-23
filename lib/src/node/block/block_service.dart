import 'dart:typed_data';

import 'package:sqlite3/sqlite3.dart';

import '../xchain/xchain_model.dart';
import 'block_model.dart';
import 'block_repository.dart';

class BlockService {
  static const int version = 1;
  final BlockRepository _repository;
  XchainModel chain;

  BlockService(Database db, this.chain) : _repository = BlockRepository(db: db);

  /// Creates a new block from a list of transactions.
  ///
  /// Calculates the [BlockModel.transactionRoot] from [transactions] list.
  /// Calculates the [BlockModel.previousHash].
  /// Updates the [transactions] in [TransactionService] with block id.
  // /// Backup the new block with [BackupService].
  // Future<BlockModel> create(List<TransactionModel> transactions) async {
  //   Uint8List transactionRoot = await _calculateTransactionRoot(transactions);
  //   BlockModel? lastBlock = _repository.getLast();
  //   Uint8List? previousHash = lastBlock == null
  //       ? await _rootBlockHash()
  //       : await _calculateHash(lastBlock);
  //   return BlockModel(
  //       previousHash: previousHash.code,
  //       xchain: xchain,
  //       transactionRoot: transactionRoot,
  //       transactionCount: transactions.length);
  // }

  /// Loads a block from the chain by its hash. If the id is provided, it loads
  /// by the id and check the hash for equality and integrity.
  Future<BlockModel> get(String id, {int? xchainId}) async {
    throw UnimplementedError();
  }

  bool validateIntegrity(BlockModel block) {
    return true;
  }

  Uint8List serialize(BlockModel block) {
    return block.header();
  }
}
