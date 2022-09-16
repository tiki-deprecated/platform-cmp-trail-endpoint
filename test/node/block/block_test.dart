/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */
import 'dart:convert';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:tiki_sdk_dart/node/block/block_model.dart';
import 'package:tiki_sdk_dart/node/block/block_repository.dart';
import 'package:tiki_sdk_dart/node/block/block_service.dart';
import 'package:tiki_sdk_dart/node/keys/keys_model.dart';
import 'package:tiki_sdk_dart/node/keys/keys_service.dart';
import 'package:tiki_sdk_dart/node/transaction/transaction_model.dart';
import 'package:tiki_sdk_dart/node/transaction/transaction_service.dart';
import 'package:tiki_sdk_dart/utils/in_mem_keys.dart';
import 'package:tiki_sdk_dart/utils/merkel_tree.dart';
import 'package:tiki_sdk_dart/utils/bytes.dart';

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
      KeysService keysService = KeysService(InMemoryKeys());
      KeysModel keys = await keysService.create();
      Database db = sqlite3.openInMemory();
      TransactionService transactionService = TransactionService(db);
      BlockService blockService = BlockService(db);
      List<TransactionModel> transactions = [];
      for (int i = 0; i < 50; i++) {
        TransactionModel txn = transactionService.build(
            keys: keys, contents: Uint8List.fromList([i]));
        transactions.add(txn);
      }
      MerkelTree merkelTree =
          MerkelTree.build(transactions.map((txn) => txn.id!).toList());
      Uint8List transactionRoot = merkelTree.root!;
      BlockModel blk = blockService.build(transactions, transactionRoot);
      for (TransactionModel transaction in transactions) {
        transaction.block = blk;
        transaction.merkelProof = merkelTree.proofs[transaction.id];
        transactionService.commit(transaction);
      }
      blockService.commit(blk);
      BlockModel? block1 = blockService.get(base64.encode(blk.id!));
      expect(block1 != null, true);
      expect(block1?.id, blk.id);
    });

    test('create block, save and validate integrity', () async {
      Database db = sqlite3.openInMemory();
      InMemoryKeys keyStorage = InMemoryKeys();
      KeysService keysService = KeysService(keyStorage);
      TransactionService transactionService = TransactionService(db);
      BlockService blockService = BlockService(db);
      KeysModel keys = await keysService.create();
      List<TransactionModel> transactions = [];
      for (int i = 0; i < 50; i++) {
        TransactionModel txn = transactionService.build(
            keys: keys, contents: Uint8List.fromList([i]));
        transactions.add(txn);
      }
      MerkelTree validationTree =
          MerkelTree.build((transactions.map((txn) => txn.id!).toList()));
      BlockModel block = blockService.build(transactions, validationTree.root!);
      for (int i = 0; i < transactions.length; i++) {
        transactions[i].block = block;
        transactions[i].merkelProof = validationTree.proofs[i];
        transactionService.commit(transactions[i]);
      }
      blockService.commit(block);
      expect(memEquals(validationTree.root!, block.transactionRoot), true);
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
      KeysService keysService = KeysService(keyStorage);
      KeysModel keys = await keysService.create();
      TransactionService transactionService = TransactionService(db);
      BlockService blockService = BlockService(db);
      List<TransactionModel> transactions = [];
      for (int i = 0; i < 50; i++) {
        TransactionModel txn = transactionService.build(
            keys: keys, contents: Uint8List.fromList([i]));
        transactions.add(txn);
      }
      MerkelTree merkelTree =
          MerkelTree.build(transactions.map((txn) => txn.id!).toList());
      Uint8List transactionRoot = merkelTree.root!;
      BlockModel blk = blockService.build(transactions, transactionRoot);
      for (TransactionModel transaction in transactions) {
        transaction.block = blk;
        transaction.merkelProof = merkelTree.proofs[transaction.id];
        transactionService.commit(transaction);
      }
      blockService.commit(blk);

      Uint8List serialized = blk.serialize(
          transactionService.serializeTransactions(base64.encode(blk.id!)));
      BlockModel newBlock = BlockModel.deserialize(serialized);
      expect(newBlock.id, blk.id);
    });
  });
}

BlockModel _generateBlockModel() => BlockModel(
    version: 1,
    previousHash: Uint8List.fromList([1, 2, 3]),
    transactionRoot: Uint8List(0),
    transactionCount: 0,
    timestamp: DateTime.now());
