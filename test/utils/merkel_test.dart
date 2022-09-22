/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:typed_data';

import 'package:pointycastle/export.dart';
import 'package:test/test.dart';
import 'package:tiki_sdk_dart/node/key/key_service.dart';
import 'package:tiki_sdk_dart/node/transaction/transaction_model.dart';
import 'package:tiki_sdk_dart/utils/merkel_tree.dart';

import '../in_mem_keys.dart';
import '../node/node_test_helpers.dart';

void main() {
  group('Merkel tests', () {
    test('Build and validate merkel proof for 1 transaction', () async {
      KeyModel keys = await KeyService(InMemoryKeys()).create();
      TransactionModel txn = generateTransactionModel(1, keys);
      txn.id = Digest("SHA3-256").process(txn.serialize());
      MerkelTree merkelTree = MerkelTree.build([txn.id!]);
      Uint8List merkelRoot = merkelTree.root!;
      Uint8List merkelProof = merkelTree.proofs[txn.id]!;
      expect(MerkelTree.validate(txn.id!, merkelProof, merkelRoot), true);
    });

    test('Build and validate merkel proof for 10 transactions', () async {
      KeyModel keys = await KeyService(InMemoryKeys()).create();
      List<TransactionModel> txns = List.generate(10, (index) {
        TransactionModel txn = generateTransactionModel(1, keys);
        txn.id = Digest("SHA3-256").process(txn.serialize());
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

    test('Build and validate merkel proof for 100 transactions', () async {
      KeyModel keys = await KeyService(InMemoryKeys()).create();
      List<TransactionModel> txns = List.generate(100, (index) {
        TransactionModel txn = generateTransactionModel(1, keys);
        txn.id = Digest("SHA3-256").process(txn.serialize());
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

    test('Build and validate merkel proof for 1000 transactions', () async {
      KeyModel keys = await KeyService(InMemoryKeys()).create();
      List<TransactionModel> txns = List.generate(100, (index) {
        TransactionModel txn = generateTransactionModel(1, keys);
        txn.id = Digest("SHA3-256").process(txn.serialize());
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
