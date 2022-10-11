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

  Database get database => _repository.db;

  /// Creates a new block to be commited later.
  ///
  /// It gets the last created block from the [db] to extract [BlockModel.previousHash]
  /// from it. If there are no blocks it means that it is the genesis block, i.e,
  /// the first block created by the chain and the [BlockModel.previousHash] will be 0.
  ///
  /// This method returns the [BlockModel] created in-memory. Its return should be used
  /// to commit the [TransactionModel]. After committing all the transactions,
  /// [commit] needs to be called to persist the block into [db].
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
  /// This method should be called only after all the transactions are committed.
  void commit(BlockModel block, {Uint8List? xchain}) =>
      _repository.save(block, xchain: xchain);

  /// Gets a [BlockModel] by [BlockModel.id]
  BlockModel? get(Uint8List id) => _repository.getById(id);

  /// Gets all the Block addresses that were not cached yet.
  List<String> getCachedIds(Uint8List address) =>
      _repository.getAllIds(address);
}
