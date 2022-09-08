/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */
import 'dart:convert';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:tiki_sdk_dart/src/node/block/block_model.dart';
import 'package:tiki_sdk_dart/src/node/block/block_repository.dart';
import 'package:tiki_sdk_dart/src/node/block/block_service.dart';
import 'package:tiki_sdk_dart/src/node/keys/keys_interface.dart';
import 'package:tiki_sdk_dart/src/node/keys/keys_model.dart';
import 'package:tiki_sdk_dart/src/node/keys/keys_service.dart';
import 'package:tiki_sdk_dart/src/node/transaction/transaction_model.dart';
import 'package:tiki_sdk_dart/src/node/transaction/transaction_service.dart';
import 'package:tiki_sdk_dart/src/utils/mem_keys_store.dart';
import 'package:tiki_sdk_dart/src/utils/merkel_tree.dart';
import 'package:tiki_sdk_dart/src/utils/bytes.dart';

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
      KeysService keysService = KeysService(MemSecureStorageStrategy());
      KeysModel keys = await keysService.create();
      Database db = sqlite3.openInMemory();
      TransactionService transactionService = TransactionService(db);
      BlockService blockService = BlockService(db, transactionService);
      List<TransactionModel> transactions = [];
      for (int i = 0; i < 50; i++) {
        TransactionModel txn = transactionService.create(
            keys: keys, contents: Uint8List.fromList([i]));
        transactions.add(txn);
      }
      BlockModel block = blockService.create(transactions);
      BlockModel? block1 = blockService.get(base64.encode(block.id!));
      expect(block1 != null, true);
      expect(block1?.id, block.id);
    });

    test('create block, save and validate integrity', () async {
      Database db = sqlite3.openInMemory();
      TestInMemoryStorage keyStorage = TestInMemoryStorage();
      KeysService keysService = KeysService(keyStorage);
      TransactionService transactionService = TransactionService(db);
      BlockService blockService = BlockService(db, transactionService);
      KeysModel keys = await keysService.create();
      List<TransactionModel> transactions = [];
      for (int i = 0; i < 50; i++) {
        TransactionModel txn = transactionService.create(
            keys: keys, contents: Uint8List.fromList([i]));
        transactions.add(txn);
      }
      BlockModel block = blockService.create(transactions);

      MerkelTree validationTree =
          MerkelTree.build((transactions.map((txn) => txn.id!).toList()));
      expect(memEquals(validationTree.root!, block.transactionRoot), true);
      for (TransactionModel txn in transactions) {
        Uint8List hash = txn.id!;
        expect(
            MerkelTree.validate(
                hash, validationTree.proofs[hash]!, block.transactionRoot),
            true);
      }
    });
  });
}

BlockModel _generateBlockModel() => BlockModel(
    version: 1,
    previousHash: Uint8List.fromList([1, 2, 3]),
    transactionRoot: Uint8List(0),
    transactionCount: 0,
    timestamp: DateTime.now());

class TestInMemoryStorage extends KeysInterface {
  Map<String, String> storage = {};

  @override
  Future<void> delete({required String key}) async => storage.remove(key);

  @override
  Future<String?> read({required String key}) async => storage[key];

  @override
  Future<void> write({required String key, required String value}) async =>
      storage[key] = value;
}
