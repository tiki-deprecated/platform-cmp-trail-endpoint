/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:tiki_sdk_dart/src/node/transaction/transaction_model.dart';
import 'package:tiki_sdk_dart/src/node/transaction/transaction_repository.dart';
import 'package:tiki_sdk_dart/src/node/transaction/transaction_service.dart';

void main() {
  group('Transaction tests', () {
    TransactionService service = TransactionService();
    test('TeansactionRepository: create and retrieve transactions', () {
      TransactionModel txn1 = _generateTransactionModel();
      TransactionModel txn2 = _generateTransactionModel();
      TransactionModel txn3 = _generateTransactionModel();
      TransactionRepository repository = TransactionRepository();
      repository.save(txn1);
      repository.save(txn2);
      repository.save(txn3);
      List<TransactionModel> txns = repository.getByBlock(null);
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

TransactionModel _generateTransactionModel() => 
  TransactionModel(address:  Uint8List.fromList('abc'.codeUnits), 
    contents: Uint8List.fromList([1,2,3]));
