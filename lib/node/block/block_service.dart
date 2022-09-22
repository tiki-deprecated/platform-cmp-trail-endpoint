/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */
/// {@category Node}
library block;

import 'dart:typed_data';

import 'package:pointycastle/export.dart';
import 'package:sqlite3/sqlite3.dart';

import '../node_service.dart';

export 'block_model.dart';
export 'block_repository.dart';

/// A service to handle block-related operations.
class BlockService {
  static const int version = 1;
  final BlockRepository _repository;

  BlockService(Database db) : _repository = BlockRepository(db);

  /// Builds a new block from a [List] of [TransactionModel] and a [transactionRoot].
  ///
  /// It gets the last created block from the [db] to extract [BlockModel.previousHash]
  /// from it. If there are no blocks it means that it is the genesis block, i.e,
  /// the first block created by the chain and the [BlockModel.previousHash] will be 0.
  ///
  /// This method returns the [BlockModel] created in-memory. Its return should be used
  /// to commit the [TransactionModel]. After committing all the transactions,
  /// [commit] needs to be called to persist the block into [db].
  /// ```
  ///  BlockModel blk = blockService.build(transactions, transactionRoot);
  ///  for (TransactionModel transaction in transactions) {
  ///    transaction.block = blk;
  ///    transaction.merkelProof = merkelTree.proofs[transaction.id];
  ///    transactionService.commit(transaction);
  ///  }
  ///  blockService.commit(blk);
  /// ```
  BlockModel create(Uint8List transactionRoot) {
    BlockModel? lastBlock = _repository.getLast();
    BlockModel block = BlockModel(
        previousHash: lastBlock == null
            ? Uint8List(1)
            : Digest("SHA3-256").process(lastBlock.serialize()),
        transactionRoot: transactionRoot);
    block.id = Digest("SHA3-256").process(block.serialize());
    return block;
  }

  /// Persists the block into [db].
  ///
  /// This method should be called just after all the transactions are committed.
  void commit(BlockModel block) => _repository.save(block);

  /// Gets a [BlockModel] by [BlockModel.id]
  BlockModel? get(String id, {String? xchainAddress}) =>
      _repository.getById(id, xchainAddress: xchainAddress);

  /// Gets the last committed block from the [db].
  BlockModel? last() => _repository.getLast();

  void validate(BlockModel blk) {}

  void add(BlockModel blk) {}
}
