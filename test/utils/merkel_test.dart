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
      Map merkelTree = calculateMerkelTree([txn.id!]);
      expect(merkelTree['merkelRoot'],
          sha256(Uint8List.fromList([...txn.id!, ...txn.id!])));
    });

    test('Validate merkel proof for 1 transaction', () {
      TransactionModel txn = _generateTransactionModel();
      txn.id = sha256(txn.serialize());
      Map merkelTree = calculateMerkelTree([txn.id!]);
      Uint8List merkelRoot = merkelTree['merkelRoot'];
      expect(merkelRoot, sha256(Uint8List.fromList([...txn.id!, ...txn.id!])));
      Uint8List merkelProof = merkelTree['merkelProof'];
      expect(validateMerkelProof(txn.id!, merkelProof, merkelRoot), true);
    });

    test('Build merkel tree from 10 transactions', () {
      List<TransactionModel> txns = List.generate(10, (index) {
        TransactionModel txn = _generateTransactionModel();
        txn.id = sha256(txn.serialize());
        txn.seq = index;
        return txn;
      });
      List<Uint8List> hashes = txns.map((e) => e.id!).toList();
      Map merkelTree = calculateMerkelTree(hashes);
      Uint8List root = merkelTree['merkelRoot'];
      expect(root.isNotEmpty, true);
    });

    test('Validate merkel proof for 10 transactions', () {
      // List<TransactionModel> txns = List.generate(4, (index) {
      //   TransactionModel txn = _generateTransactionModel();
      //   txn.id = sha256(txn.serialize());
      //   txn.seq = index;
      //   return txn;
      // });
      List<Uint8List> hashes = [
        Uint8List.fromList([1]), 
        Uint8List.fromList([2]), 
        Uint8List.fromList([3]), 
        Uint8List.fromList([4]), 
        Uint8List.fromList([5]), 
        Uint8List.fromList([6])];
      //txns.map((e) => e.id!).toList();

      Map merkelTree = calculateMerkelTree(hashes);
      Uint8List root = merkelTree['merkelRoot'];
      expect(root.isNotEmpty, true);
      List<Uint8List> merkelProof = merkelTree['merkelProof'];
      expect(validateMerkelProof(hashes[0], merkelProof[0], root), true);
    });

    test('Validar merkel tree from 100 transactions', () {
      List<TransactionModel> txns = List.generate(10, (index) {
        TransactionModel txn = _generateTransactionModel();
        txn.id = sha256(txn.serialize());
        txn.seq = index;
        return txn;
      });
      List<Uint8List> hashes = txns.map((e) => e.id!).toList();
      Map merkelTree = calculateMerkelTree(hashes);
      Uint8List root = merkelTree['merkelRoot'];
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
