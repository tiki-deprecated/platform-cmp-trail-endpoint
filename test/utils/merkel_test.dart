/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:tiki_sdk_dart/src/node/transaction/transaction_model.dart';
import 'package:tiki_sdk_dart/src/utils/merkel_tree.dart';
import 'package:tiki_sdk_dart/src/utils/utils.dart';

void main() {
  group('Merkel tests', () {
    test('Build and validate merkel proof for 1 transaction', () {
      TransactionModel txn = generateTransactionModel(1);
      txn.id = sha256(txn.serialize());
      MerkelTree merkelTree = MerkelTree.build([txn.id!]);
      Uint8List merkelRoot = merkelTree.root!;
      Uint8List merkelProof = merkelTree.proofs[txn.id]!;
      expect(MerkelTree.validate(txn.id!, merkelProof, merkelRoot), true);
    });

    test('Build and validate merkel proof for 10 transactions', () {
      List<TransactionModel> txns = List.generate(10, (index) {
        TransactionModel txn = generateTransactionModel(1);
        txn.id = sha256(txn.serialize());
        return txn;
      });
      MerkelTree merkelTree =
          MerkelTree.build(txns.map((txn) => txn.id!).toList());
      for (int i = 0; i < txns.length; i++) {
        Uint8List hash = txns[i].id!;
        bool val = MerkelTree.validate(
            hash, merkelTree.proofs[hash]!, merkelTree.root!);
        expect(val, true);
      }
    });

    test('Build and validate merkel proof for 100 transactions', () {
      List<TransactionModel> txns = List.generate(100, (index) {
        TransactionModel txn = generateTransactionModel(1);
        txn.id = sha256(txn.serialize());
        return txn;
      });
      MerkelTree merkelTree =
          MerkelTree.build(txns.map((txn) => txn.id!).toList());
      for (int i = 0; i < txns.length; i++) {
        Uint8List hash = txns[i].id!;
        bool val = MerkelTree.validate(
            hash, merkelTree.proofs[hash]!, merkelTree.root!);
        expect(val, true);
      }
    });

    test('Build and validate merkel proof for 1000 transactions', () {
      List<TransactionModel> txns = List.generate(100, (index) {
        TransactionModel txn = generateTransactionModel(1);
        txn.id = sha256(txn.serialize());
        return txn;
      });
      MerkelTree merkelTree =
          MerkelTree.build(txns.map((txn) => txn.id!).toList());
      for (int i = 0; i < txns.length; i++) {
        Uint8List hash = txns[i].id!;
        bool val = MerkelTree.validate(
            hash, merkelTree.proofs[hash]!, merkelTree.root!);
        expect(val, true);
      }
    });
  });
}

TransactionModel generateTransactionModel(int index) {
  TransactionModel txn = TransactionModel.fromMap({
    'address': Uint8List.fromList('abc'.codeUnits),
    'timestamp': DateTime.now(),
    'signature': Uint8List.fromList(
        (DateTime.now().millisecondsSinceEpoch + index).toString().codeUnits),
    'contents': Uint8List.fromList([1, 2, 3]),
    'version': 1,
    'asset_ref': Uint8List(1)
  });
  return txn;
}
