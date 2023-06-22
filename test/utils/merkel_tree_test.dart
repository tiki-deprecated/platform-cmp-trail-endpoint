/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';
import 'package:tiki_trail/key.dart';
import 'package:tiki_trail/node/transaction/transaction_model.dart';
import 'package:tiki_trail/node/transaction/transaction_service.dart';
import 'package:tiki_trail/utils/merkel_tree.dart';
import 'package:uuid/uuid.dart';

import '../fixtures/idp.dart' as fixture;

void main() {
  group('Merkel Tests', () {
    test('Build/Validate - 1 Txn - Success', () async {
      TransactionService transactionService =
          TransactionService(sqlite3.openInMemory(), fixture.idp);
      TransactionModel txn = await transactionService.create(
          Uint8List.fromList(utf8.encode(const Uuid().v4())),
          await fixture.key);

      txn.id = Digest("SHA3-256").process(txn.serialize());
      MerkelTree merkelTree = MerkelTree.build([txn.id!]);
      Uint8List merkelRoot = merkelTree.root!;
      Uint8List merkelProof = merkelTree.proofs[txn.id]!;
      expect(MerkelTree.validate(txn.id!, merkelProof, merkelRoot), true);
    });

    test('Build/Validate - 10 Txn - Success', () async {
      Key key = await fixture.key;
      TransactionService transactionService =
          TransactionService(sqlite3.openInMemory(), fixture.idp);
      List<TransactionModel> txns = await Future.wait(List.generate(
          10,
          (index) => transactionService.create(
              Uint8List.fromList(utf8.encode(const Uuid().v4())), key)));

      MerkelTree merkelTree =
          MerkelTree.build(txns.map((txn) => txn.id!).toList());
      for (int i = 0; i < txns.length; i++) {
        Uint8List hash = txns[i].id!;
        bool val = MerkelTree.validate(
            hash, merkelTree.proofs[hash]!, merkelTree.root!);
        expect(val, true);
      }
    });

    test('Build/Validate - 100 Txn - Success', () async {
      Key key = await fixture.key;
      TransactionService transactionService =
          TransactionService(sqlite3.openInMemory(), fixture.idp);
      List<TransactionModel> txns = await Future.wait(List.generate(
          100,
          (index) => transactionService.create(
              Uint8List.fromList(utf8.encode(const Uuid().v4())), key)));
      MerkelTree merkelTree =
          MerkelTree.build(txns.map((txn) => txn.id!).toList());
      for (int i = 0; i < txns.length; i++) {
        Uint8List hash = txns[i].id!;
        bool val = MerkelTree.validate(
            hash, merkelTree.proofs[hash]!, merkelTree.root!);
        expect(val, true);
      }
    });

    test('Build/Validate - 1000 Txn - Success', () async {
      Key key = await fixture.key;
      TransactionService transactionService =
          TransactionService(sqlite3.openInMemory(), fixture.idp);
      List<TransactionModel> txns = await Future.wait(List.generate(
          100,
          (index) => transactionService.create(
              Uint8List.fromList(utf8.encode(const Uuid().v4())), key)));
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
