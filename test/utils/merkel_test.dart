/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:tiki_sdk_dart/src/node/transaction/transaction_model.dart';
import 'package:tiki_sdk_dart/src/utils/utils.dart';

void main() {
  group('Merkel tests', () {
    test('Build merkel tree from 1 transaction', () {
      TransactionModel txn = _generateTransactionModel();
      txn.id = sha256(txn.serialize());
      Uint8List root = calculateMerkelRoot([txn.id!]);
      expect(root, txn.id);
    });

    test('Build merkel tree from 10 transactions', () {
      List<TransactionModel> txns = List.generate(10, (index) {
        TransactionModel txn = _generateTransactionModel();
        txn.id = sha256(txn.serialize());
        txn.seq = index;
        return txn;
      });
      List<Uint8List> hashes = txns.map((e) => e.id!).toList();
      Uint8List root = calculateMerkelRoot(hashes);
      expect(root.isNotEmpty, true);
    });

    test('Build merkel tree from 100 transactions', () {
      List<TransactionModel> txns = List.generate(100, (index) {
        TransactionModel txn = _generateTransactionModel();
        txn.id = sha256(txn.serialize());
        txn.seq = index;
        return txn;
      });
      List<Uint8List> hashes = txns.map((e) => e.id!).toList();
      Uint8List root = calculateMerkelRoot(hashes);
      expect(root.isNotEmpty, true);
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
