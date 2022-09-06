import 'dart:typed_data';

import 'package:sqlite3/sqlite3.dart';

import '../../utils/merkel_tree.dart';
import '../../utils/page_model.dart';
import '../../utils/utils.dart';
import '../transaction/transaction_model.dart';
import '../transaction/transaction_service.dart';
import 'block_model.dart';
import 'block_repository.dart';

class BlockService {
  static const int version = 1;
  final BlockRepository _repository;
  final TransactionService _transactionService;

  BlockService(Database db, this._transactionService)
      : _repository = BlockRepository(db);

  /// Create a new block from a list of transactions.
  ///
  /// Calculate the [MerkelTree] from [transactions] list.
  /// Calculate the [BlockModel.previousHash].
  /// Update the [transactions] with block id and merkel proof;
  /// Backup the new block with [BackupService].
  /// Return the [BlockModelResponse] with [BlockModel] and [MerkelTree].
  BlockModel create(List<TransactionModel> transactions) {
    List<Uint8List> hashes = transactions.map((e) => e.id!).toList();
    MerkelTree merkelTree = MerkelTree.build(hashes);
    Uint8List transactionRoot = merkelTree.root!;
    BlockModel? lastBlock = _repository.getLast();
    BlockModel block = BlockModel(
        previousHash:
            lastBlock == null ? Uint8List(1) : sha256(lastBlock.header()),
        transactionRoot: transactionRoot,
        transactionCount: transactions.length);
    block.id = sha256(block.header());
    for (TransactionModel transaction in transactions) {
      transaction.block = block;
      transaction.merkelProof = merkelTree.proofs[transaction.id];
      _transactionService.commit(transaction);
    }
    _repository.save(block);
    return block;
  }

  /// Remove the [blk] from local database.
  void prune(BlockModel blk) => _repository.prune(blk);

  /// Add [blockModel] in local database.
  void add(BlockModel blockModel) => _repository.save(blockModel);

  /// Load the [BlockModel] from local database by [BlockModel.id]
  BlockModel? get(String id) => _repository.getById(id);

  /// Load the [BlockModel] by [XchainModel.address]. If no xchain uri is provided
  /// it loads from local database.
  PageModel<BlockModel> getByChain(String xchainAddress) {
    return _repository.getByChain(xchainAddress);
  }

  PageModel<BlockModel> getLocal() {
    return _repository.getLocal();
  }

  /// Get the last block in the chain. If no chain is provided, get the last from
  /// localchain.
  BlockModel? getLast(String xchainAddress) => 
  _repository.getLast(xchainIAddress: xchainAddress);

}
