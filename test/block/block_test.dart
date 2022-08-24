/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:tiki_sdk_dart/src/node/block/block_model.dart';
import 'package:tiki_sdk_dart/src/node/block/block_repository.dart';
import 'package:tiki_sdk_dart/src/node/block/block_service.dart';
import 'package:tiki_sdk_dart/src/node/keys/keys_model.dart';
import 'package:tiki_sdk_dart/src/node/keys/keys_secure_storage_interface.dart';
import 'package:tiki_sdk_dart/src/node/keys/keys_service.dart';
import 'package:tiki_sdk_dart/src/node/transaction/transaction_model.dart';
import 'package:tiki_sdk_dart/src/node/transaction/transaction_service.dart';
import 'package:tiki_sdk_dart/src/node/xchain/xchain_service.dart';
import 'package:tiki_sdk_dart/src/utils/page_model.dart';

void main() {
  group('block repository tests', () {
    test('save blocks, retrieve all', () {
      Database db = sqlite3.openInMemory();
      BlockRepository repository = BlockRepository(db: db);
      BlockModel block1 = _generateBlockModel();
      repository.save(block1);
      expect(1, 1);
    });

    test('create block, save and retrive', () async {
      KeysService keysService = KeysService(TestInMemoryStorage());
      KeysModel keys = await keysService.create();
      Database db = sqlite3.openInMemory();
      BlockService blockService = BlockService(db);
      TransactionService transactionService = TransactionService(keysService);
      XchainService xchainService = XchainService(db);
      List<TransactionModel> transactions = [];
      for (int i = 0; i < 50; i++) {
        TransactionModel txn = await transactionService.create(
            address: base64Url.encode(keys.address),
            contents: Uint8List.fromList([i]));
        transactions.add(txn);
      }
      BlockModel block = blockService.create(transactions);
      BlockModel? block1 = blockService.get(block.id!);
      expect(block1 != null, true);
      expect(block1?.id, block.id);
    });
  });
}

BlockModel _generateBlockModel() => BlockModel(
    version: 1,
    previousHash: Uint8List.fromList([1,2,3]),
    transactionRoot: Uint8List(0),
    transactionCount: 0,
    timestamp: DateTime.now());

class TestInMemoryStorage extends KeysSecureStorageInterface {
  Map<String, String> storage = {};

  @override
  Future<void> delete({required String key}) async => storage.remove(key);

  @override
  Future<String?> read({required String key}) async => storage[key];

  @override
  Future<void> write({required String key, required String value}) async =>
      storage[key] = value;
}
