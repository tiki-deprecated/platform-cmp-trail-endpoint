/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:typed_data';

import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';
import 'package:tiki_sdk_dart/src/node/block/block_repository.dart';
import 'package:tiki_sdk_dart/src/node/merkel/merkel_service.dart';
import 'package:tiki_sdk_dart/src/node/merkel/merkel_tree.dart';
import 'package:tiki_sdk_dart/src/node/transaction/transaction_model.dart';
import 'package:tiki_sdk_dart/src/node/transaction/transaction_repository.dart';
import 'package:tiki_sdk_dart/src/node/xchain/xchain_repository.dart';
import 'package:tiki_sdk_dart/src/utils/utils.dart';

void main() {
  group('Merkel tests', () {
    test('Build merkel tree from 1 transaction', () {
      TransactionModel txn = _generateTransactionModel();
      txn.id = sha256(txn.serialize());
      MerkelTree tree = MerkelService().buildTree([txn]);
      expect(tree.height, 1);
      expect(tree.root, txn.id);
    });

    test('Build merkel tree from 10 transactions', () {
      List<TransactionModel> txns = List.generate(10, (index) {
        TransactionModel txn = _generateTransactionModel();
        txn.id = sha256(txn.serialize());
        txn.seq = index;
        return txn;
      });
      MerkelTree tree = MerkelService().buildTree(txns);
      expect(tree.height, 4);
      expect(tree.nodes[1][0].includedTransactions.contains(txns[0]), true);
    });

    test('Build merkel tree from 100 transactions', () {
       List<TransactionModel> txns = List.generate(100, (index) {
        TransactionModel txn = _generateTransactionModel();
        txn.id = sha256(txn.serialize());
        txn.seq = index;
        return txn;
      });
      MerkelTree tree = MerkelService().buildTree(txns);
      expect(tree.height, 7);
      expect(tree.nodes[1][0].includedTransactions.contains(txns[0]), true);
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
