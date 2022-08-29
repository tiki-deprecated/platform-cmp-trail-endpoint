/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:typed_data';

import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';
import 'package:tiki_sdk_dart/src/node/block/block_repository.dart';
import 'package:tiki_sdk_dart/src/node/transaction/transaction_model.dart';
import 'package:tiki_sdk_dart/src/node/transaction/transaction_repository.dart';
import 'package:tiki_sdk_dart/src/node/xchain/xchain_repository.dart';

void main() {
  group('Transaction tests', () {
    Database db = sqlite3.openInMemory();
    TransactionRepository repository = TransactionRepository(db: db);
    BlockRepository blkRepo =  BlockRepository(db);
    XchainRepository chainRepo =  XchainRepository(db: db);
    test('TransactionRepository: create and retrieve transactions', () {
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

    test('Transaction Service: create transaction', () {
      
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
