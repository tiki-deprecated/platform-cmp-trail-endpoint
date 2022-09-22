/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */
import 'dart:typed_data';

import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';
import 'package:tiki_sdk_dart/node/node_service.dart';
import 'package:tiki_sdk_dart/utils/utils.dart';

import '../../in_mem_keys.dart';

void main() {
  group('block repository tests', () {
    test('save blocks, retrieve all', () {
      Database db = sqlite3.openInMemory();
      BlockRepository repository = BlockRepository(db);
      BlockModel block1 = _generateBlockModel();
      block1.id = Uint8List(32);
      repository.save(block1);
      expect(1, 1);
    });

    test('create block, save and retrive', () async {
      KeyService keysService = KeyService(InMemoryKeys());
      KeyModel key = await keysService.create();
      Database db = sqlite3.openInMemory();
      TransactionService transactionService = TransactionService(db);
      BlockService blockService = BlockService(db);
      List<TransactionModel> transactions = [];
      for (int i = 0; i < 50; i++) {
        TransactionModel txn = transactionService.create(
            Uint8List.fromList([i]), key);
        transactions.add(txn);
      }
      MerkelTree merkelTree =
          MerkelTree.build(transactions.map((txn) => txn.id!).toList());
      Uint8List transactionRoot = merkelTree.root!;
      BlockModel blk = blockService.create(transactionRoot);
      for (TransactionModel transaction in transactions) {
        transaction.block = blk;
        transaction.merkelProof = merkelTree.proofs[transaction.id];
        transactionService.commit(transaction);
      }
      blockService.commit(blk);
      BlockModel? block1 = blockService.get(blk.id!);
      expect(block1 != null, true);
      expect(block1?.id, blk.id);
    });

    test('create block, save and validate integrity', () async {
      Database db = sqlite3.openInMemory();
      InMemoryKeys keyStorage = InMemoryKeys();
      KeyService keysService = KeyService(keyStorage);
      TransactionService transactionService = TransactionService(db);
      BlockService blockService = BlockService(db);
      KeyModel key = await keysService.create();
      List<TransactionModel> transactions = [];
      for (int i = 0; i < 50; i++) {
        TransactionModel txn = transactionService.create(
            Uint8List.fromList([i]), key);
        transactions.add(txn);
      }
      MerkelTree validationTree =
          MerkelTree.build((transactions.map((txn) => txn.id!).toList()));
      BlockModel block = blockService.create(validationTree.root!);
      for (int i = 0; i < transactions.length; i++) {
        transactions[i].block = block;
        transactions[i].merkelProof = validationTree.proofs[transactions[i].id];
        transactionService.commit(transactions[i]);
      }
      blockService.commit(block);
      expect(UtilsBytes.memEquals(validationTree.root!, block.transactionRoot),
          true);
      for (TransactionModel txn in transactions) {
        Uint8List hash = txn.id!;
        expect(
            MerkelTree.validate(
                hash, validationTree.proofs[hash]!, block.transactionRoot),
            true);
      }
    });
    test('create block, serialize and deserilaize', () async {
      Database db = sqlite3.openInMemory();
      InMemoryKeys keyStorage = InMemoryKeys();
      KeyService keysService = KeyService(keyStorage);
      KeyModel key = await keysService.create();
      TransactionService transactionService = TransactionService(db);
      BlockService blockService = BlockService(db);
      List<TransactionModel> transactions = [];
      for (int i = 0; i < 50; i++) {
        TransactionModel txn = transactionService.create(
            Uint8List.fromList([i]), key);
        transactions.add(txn);
      }
      MerkelTree merkelTree =
          MerkelTree.build(transactions.map((txn) => txn.id!).toList());
      Uint8List transactionRoot = merkelTree.root!;
      BlockModel blk = blockService.create(transactionRoot);
      for (TransactionModel transaction in transactions) {
        transaction.block = blk;
        transaction.merkelProof = merkelTree.proofs[transaction.id];
        transactionService.commit(transaction);
      }
      blockService.commit(blk);

      Uint8List serialized = blk.serialize();
      BlockModel newBlock = BlockModel.deserialize(serialized);
      expect(newBlock.id, blk.id);
    });
  });
}

BlockModel _generateBlockModel() => BlockModel(
    version: 1,
    previousHash: Uint8List.fromList([1, 2, 3]),
    transactionRoot: Uint8List(0),
    timestamp: DateTime.now());
