/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:typed_data';

import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';
import 'package:tiki_sdk_dart/src/node/block/block_model.dart';
import 'package:tiki_sdk_dart/src/node/block/block_model_reponse.dart';
import 'package:tiki_sdk_dart/src/node/block/block_repository.dart';
import 'package:tiki_sdk_dart/src/node/block/block_service.dart';
import 'package:tiki_sdk_dart/src/node/keys/keys_model.dart';
import 'package:tiki_sdk_dart/src/node/keys/keys_service.dart';
import 'package:tiki_sdk_dart/src/node/transaction/transaction_model.dart';
import 'package:tiki_sdk_dart/src/node/transaction/transaction_repository.dart';
import 'package:tiki_sdk_dart/src/node/transaction/transaction_service.dart';
import 'package:tiki_sdk_dart/src/node/xchain/xchain_repository.dart';

import '../block/block_test.dart';

void main() {
  group('Transaction tests', () {
    test('TransactionRepository: create and retrieve transactions', () {
      Database db = sqlite3.openInMemory();
      TransactionRepository repository = TransactionRepository(db: db);
      BlockRepository blkRepo = BlockRepository(db);
      XchainRepository chainRepo = XchainRepository(db: db);
      TransactionModel txn1 = _generateTransactionModel();
      TransactionModel txn2 = _generateTransactionModel();
      TransactionModel txn3 = _generateTransactionModel();
      repository.save(txn1);
      repository.save(txn2);
      repository.save(txn3);
      List<TransactionModel> txns = repository.getBlockNull();
      expect(txns.length, 3);
    });

    test('Transaction Model: serialize, deserialize', () {
      TransactionModel original = TransactionModel(
          version: 1,
          address: Uint8List.fromList('abc'.codeUnits),
          timestamp: DateTime(2022),
          assetRef: Uint8List.fromList('test://test_chain/'.codeUnits),
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

      XchainRepository xchainRepository = XchainRepository(db: db);

      BlockService blockService = BlockService(db);
      TransactionService transactionService = TransactionService(db);

      KeysModel keys = await keysService.create();
      List<TransactionModel> transactions = [];
      for (int i = 0; i < 50; i++) {
        TransactionModel txn = await transactionService.create(
            keys: keys, contents: Uint8List.fromList([i]));
        transactions.add(txn);
        expect(
            TransactionService.checkAuthor(txn, keys.privateKey.public), false);

        expect(TransactionService.checkIntegrity(txn), true);
      }
      BlockModelResponse blockResponse = blockService.create(transactions);
      BlockModel block = blockResponse.block;

      for (TransactionModel transaction in transactions) {
        transaction.block = block;
        transaction.merkelProof =
            blockResponse.merkelTree.proofs[transaction.id!];
        transactionService.update(transaction, keys);
        expect(TransactionService.checkInclusion(transaction, block), true);
      }
    });
  });
}

TransactionModel _generateTransactionModel() {
  TransactionModel txn = TransactionModel.fromMap({
    'address': Uint8List.fromList('abc'.codeUnits),
    'timestamp': DateTime.now(),
    'signature': Uint8List.fromList(
        DateTime.now().millisecondsSinceEpoch.toString().codeUnits),
    'contents': Uint8List.fromList([1, 2, 3]),
    'version': 1,
    'asset_ref': Uint8List(1)
  });
  return txn;
}
