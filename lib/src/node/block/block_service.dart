import 'dart:typed_data';

import 'package:pointycastle/export.dart';
import 'package:sqlite3/sqlite3.dart';

import '../../utils/merkel_tree.dart';
import '../../utils/page_model.dart';
import '../transaction/transaction_model.dart';
import 'block_model.dart';
import 'block_repository.dart';

class BlockService {
  static const int version = 1;
  final BlockRepository _repository;

  BlockService(Database db)
      : _repository = BlockRepository(db);

  /// Create a new block from a list of transactions.
  ///
  /// Calculate the [MerkelTree] from [transactions] list.
  /// Calculate the [BlockModel.previousHash].
  /// Update the [transactions] with block id and merkel proof;
  /// Backup the new block with [BackupService].
  /// Return the [BlockModelResponse] with [BlockModel] and [MerkelTree].
  BlockModel create(List<TransactionModel> transactions, Uint8List transactionRoot) {
   BlockModel? lastBlock = _repository.getLast();
    BlockModel block = BlockModel(
        previousHash: lastBlock == null
            ? Uint8List(1)
            : Digest("SHA3-256").process(lastBlock.header()),
        transactionRoot: transactionRoot,
        transactionCount: transactions.length);
    block.id = Digest("SHA3-256").process(block.header());
    return block;
  }

  void commit(BlockModel block) => _repository.save(block);

  BlockModel? get(String id) => _repository.getById(id);

  PageModel<BlockModel> getLocal() {
    return _repository.getLocal();
  }

  BlockModel? getLast(String xchainAddress) =>
      _repository.getLast(xchainIAddress: xchainAddress);

}
