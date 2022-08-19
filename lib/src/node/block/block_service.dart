import 'package:sqlite3/sqlite3.dart';

import '../transaction/transaction_model.dart';
import '../xchain/xchain_model.dart';
import 'block_model.dart';
import 'block_repository.dart';

class BlockService {
  static const int version = 1;
  BlockRepository _repository;
  XchainModel chain;

  BlockService(Database db, this.chain) : _repository = BlockRepository(db);

  /// Creates a new block from a list of transactions.
  ///
  /// Calculates the [BlockModel.transactionRoot] from [transactions] list.
  /// Calculates the [BlockModel.previousHash].
  /// Updates the [transactions] in [TransactionService] with block id.
  /// Backup the new block with [BackupService].
  Future<BlockModel> create(List<TransactionModel> transactions) async {
    throw UnimplementedError();
  }

  /// Loads a block from the chain by its hash. If the id is provided, it loads
  /// by the id and check the hash for equality and integrity.
  Future<BlockModel> get(String id, {int? xchainId}) async {
    throw UnimplementedError();
  }

  /// Validates the block.
  Future<bool> validate(BlockModel block) async {
    throw UnimplementedError();
  }

  /// Serializes the block to be included in the chain.
  String serialize(BlockModel block) {
    throw UnimplementedError();
  }

  Future<String> _calculateHash(BlockModel block) async {
    return '';
  }

  Future<String> _calculateTransactionRoot(
      List<TransactionModel> transactions) async {
    return '';
  }
}
