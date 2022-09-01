import 'dart:convert';
import 'dart:typed_data';

import 'package:sqlite3/sqlite3.dart';

import '../../utils/merkel_tree.dart';
import '../../utils/page_model.dart';
import '../../utils/utils.dart';
import '../transaction/transaction_model.dart';
import 'block_model.dart';
import 'block_model_reponse.dart';
import 'block_repository.dart';

class BlockService {
  static const int version = 1;
  final BlockRepository _repository;

  BlockService(
    Database? db,
  ) : _repository = BlockRepository(db);

  /// Create a new block from a list of transactions.
  ///
  /// Calculate the [MerkelTree] from [transactions] list.
  /// Calculate the [BlockModel.previousHash].
  /// Backup the new block with [BackupService].
  /// Return the [BlockModelResponse] with [BlockModel] and [MerkelTree].
  BlockModelResponse create(List<TransactionModel> transactions) {
    List<Uint8List> hashes = transactions.map((e) => e.id!).toList();
    MerkelTree merkelTree = MerkelTree.build(hashes);
    Uint8List transactionRoot = merkelTree.root!;
    BlockModel? lastBlock = _repository.getLast(
        'tiki://${transactions.first.address}'); //todo there should be no xchain ref for local
    BlockModel block = BlockModel(
        previousHash:
            lastBlock == null ? Uint8List(1) : sha256(lastBlock.header()),
        transactionRoot: transactionRoot,
        transactionCount: transactions.length);
    block.id = sha256(block.header());
    _repository.save(block);
    return BlockModelResponse(block, merkelTree);
  }

  /// Load the [BlockModel] from local database by [BlockModel.id]
  BlockModel? get(Uint8List id) => _repository.getById(base64Url.encode(id));

  //todo xchainUri should be nullable & optional
  /// Load the [BlockModel] by [XchainModel.uri]. If no xchain uri is provided
  /// it loads from local database.
  PageModel<BlockModel> getByChain(String xchainUri) {
    return _repository.getByChain(xchainUri);
  }

  //todo xchainUri should be nullable & optional
  /// Get the last block in the chain. If no chain is provided, get the last from
  /// localchain.
  BlockModel? getLast(String xchainUri) => _repository.getLast(xchainUri);

  /// Remove the [blk] from local database.
  void discard(BlockModel blk) => _repository.remove(blk);

  /// Add [blockModel] in local database.
  void add(BlockModel blockModel) => _repository.save(blockModel);
}
