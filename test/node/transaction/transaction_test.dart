/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:typed_data';

import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';
import 'package:tiki_sdk_dart/src/node/block/block_model.dart';
import 'package:tiki_sdk_dart/src/node/block/block_repository.dart';
import 'package:tiki_sdk_dart/src/node/block/block_service.dart';
import 'package:tiki_sdk_dart/src/node/keys/keys_model.dart';
import 'package:tiki_sdk_dart/src/node/keys/keys_service.dart';
import 'package:tiki_sdk_dart/src/node/transaction/transaction_model.dart';
import 'package:tiki_sdk_dart/src/node/transaction/transaction_repository.dart';
import 'package:tiki_sdk_dart/src/node/transaction/transaction_service.dart';
import 'package:tiki_sdk_dart/src/utils/mem_keys_store.dart';
import 'package:tiki_sdk_dart/src/utils/merkel_tree.dart';

import '../block/block_test.dart';
import '../node_test_helpers.dart';

void main() {
  group('Transaction tests', () {
    test('TransactionRepository: create and retrieve transactions', () async {
      Database db = sqlite3.openInMemory();
      TransactionRepository repository = TransactionRepository(db);
      BlockRepository blockRepository = BlockRepository(db);
      KeysModel keys = await KeysService(MemSecureStorageStrategy()).create();
      //BlockRepository blkRepo = BlockRepository(db);
      TransactionModel txn1 = generateTransactionModel(1, keys);
      TransactionModel txn2 = generateTransactionModel(2, keys);
      TransactionModel txn3 = generateTransactionModel(3, keys);
      repository.save(txn1);
      repository.save(txn2);
      repository.save(txn3);
      List<TransactionModel> txns = repository.getPending();
      expect(txns.length, 3);
    });

    test('Transaction Model: serialize, deserialize', () {
      TransactionModel original = TransactionModel(
          version: 1,
          address: Uint8List.fromList('abc'.codeUnits),
          timestamp: DateTime(2022),
          assetRef: 'AA==',
          contents: Uint8List.fromList('hello world'.codeUnits));
      Uint8List serialized = original.serialize();
      TransactionModel deserialized = TransactionModel.deserialize(serialized);
      expect(original.version, deserialized.version);
      expect(original.address, deserialized.address);
      expect(original.assetRef, deserialized.assetRef);
      expect(original.signature, deserialized.signature);
      expect(original.contents, deserialized.contents);
    });

    test('''Transaction Service: create transaction and check inclusion, 
    integrity and authorship''', () async {
      Database db = sqlite3.openInMemory();
      TestInMemoryStorage keyStorage = TestInMemoryStorage();
      KeysService keysService = KeysService(keyStorage);

      TransactionService transactionService = TransactionService(db);
      BlockService blockService = BlockService(db);

      KeysModel keys = await keysService.create();
      List<TransactionModel> transactions = [];
      for (int i = 0; i < 50; i++) {
        TransactionModel txn = transactionService.create(
            keys: keys, contents: Uint8List.fromList([i]));
        transactions.add(txn);
        expect(TransactionService.validateAuthor(txn, keys.privateKey.public),
            true);

        expect(TransactionService.validateIntegrity(txn), true);
      }
      MerkelTree merkelTree =
          MerkelTree.build(transactions.map((txn) => txn.id!).toList());
      BlockModel block = blockService.create(transactions, merkelTree.root!);
      for (int i = 0; i < transactions.length; i++) {
        TransactionModel transaction = transactions[i];
        transaction.block = block;
        transaction.merkelProof = merkelTree.proofs[transaction.id];
        transactionService.commit(transaction);
      }
      blockService.commit(block);
      List<TransactionModel> txns = transactionService.getByBlock(block.id!);
      for (TransactionModel transaction in txns) {
        expect(TransactionService.validateInclusion(transaction, block), true);
      }
    });

    test('Transaction serialize and deserialize', () async {
      KeysModel keys = await KeysService(MemSecureStorageStrategy()).create();
      Database db = sqlite3.openInMemory();
      TestInMemoryStorage keyStorage = TestInMemoryStorage();
      KeysService keysService = KeysService(keyStorage);

      TransactionService transactionService = TransactionService(db);
      BlockService blockService = BlockService(db);
      TransactionModel txn = transactionService.create(
          keys: keys, contents: Uint8List.fromList([0]));
      expect(
          TransactionService.validateAuthor(txn, keys.privateKey.public), true);
      Uint8List serialized = txn.serialize(includeSignature: true);
      TransactionModel newTxn = TransactionModel.deserialize(serialized);
      expect(TransactionService.validateAuthor(newTxn, keys.privateKey.public),
          true);
      expect(txn.version, newTxn.version);
      expect(base64.encode(txn.address), base64.encode(newTxn.address));
      expect(txn.timestamp.millisecondsSinceEpoch ~/ 1000,
          newTxn.timestamp.millisecondsSinceEpoch ~/ 1000);
      expect(txn.assetRef, newTxn.assetRef);
      expect(base64.encode(txn.signature!), base64.encode(newTxn.signature!));
      expect(base64.encode(txn.contents), base64.encode(newTxn.contents));
    });
  });
}
