import 'dart:convert';
import 'dart:typed_data';

import 'package:sqlite3/sqlite3.dart';

import '../../utils/merkel_tree.dart';
import '../../utils/page_model.dart';
import '../../utils/utils.dart';
import '../transaction/transaction_model.dart';
import '../transaction/transaction_service.dart';
import 'block_model.dart';
import 'block_model_reponse.dart';
import 'block_repository.dart';

class BlockService {
  static const int version = 1;
  final BlockRepository _repository;

  BlockService(
    Database? db,
  ) : _repository = BlockRepository(db);

  /// Creates a new block from a list of transactions.
  ///
  /// Calculates the [BlockModel.transactionRoot] from [transactions] list.
  /// Calculates the [BlockModel.previousHash].
  /// Updates the [transactions] in [TransactionService] with block id.
  /// Backup the new block with [BackupService].
  BlockModelResponse create(List<TransactionModel> transactions) {
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
    _repository.save(block);
    return BlockModelResponse(block, merkelTree);
  }

  /// Loads a block from the chain by its hash. If the id is provided, it loads
  /// by the id and check the hash for equality and integrity.
  BlockModel? get(Uint8List id) => _repository.getById(base64Url.encode(id));

  bool validateIntegrity(BlockModel block) {
    return true;
  }

  Uint8List serialize(BlockModel block) {
    return block.header();
  }

  PageModel<BlockModel> getByChain(String? xchainUri) {
    return xchainUri == null
        ? _repository.getLocal()
        : _repository.getByChain(xchainUri);
  }

  void discard(BlockModel blk) => _repository.remove(blk);
}
