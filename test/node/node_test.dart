import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:tiki_sdk_dart/src/node/node_service.dart';
import 'package:tiki_sdk_dart/src/node/transaction/transaction_model.dart';
import 'package:tiki_sdk_dart/src/node/transaction/transaction_service.dart';

void main() {
  group('Node tests', () {
    test('create keys', () async {
      NodeService nodeService = await NodeService().init(apiKey: 'test');
      expect(nodeService.publicKey.encode().isNotEmpty, true);
    });
    test('create transactions', () async {
      NodeService nodeService = await NodeService().init(apiKey: 'test');
      TransactionModel txn =
          nodeService.write(Uint8List.fromList('test contents'.codeUnits));
      expect(txn.id != null, true);
      expect(TransactionService.checkAuthor(txn, nodeService.publicKey), false);
      expect(TransactionService.checkIntegrity(txn), true);
    });
    test('create block by transactions size', () async {
      NodeService nodeService = await NodeService().init(apiKey: 'test');
      int size = 0;
      while (size < 100000) {
        TransactionModel txn =
            nodeService.write(Uint8List.fromList('test contents'.codeUnits));
        size += txn.serialize().buffer.lengthInBytes;
      }
      await Future.delayed(const Duration(seconds: 5));
      List<TransactionModel> txns = nodeService.getTxnByChain();
      expect(txns.isNotEmpty, true);
      expect(
          () => txns.firstWhere((txn) => txn.block == null), throwsStateError);
    });
    test('create block by last transaction creation time', () async {
      NodeService nodeService = await NodeService()
          .init(blkInterval: const Duration(seconds: 20), apiKey: 'test');
      TransactionModel txn =
          nodeService.write(Uint8List.fromList('test contents'.codeUnits));
      List<TransactionModel> txns = nodeService.getTxnByChain();
      expect(txns.isEmpty, true);
      await Future.delayed(const Duration(seconds: 20));
      txns = nodeService.getTxnByChain();
      expect(txns.isNotEmpty, true);
      expect(
          () => txns.firstWhere((txn) => txn.block == null), throwsStateError);
    });
    test('retrieve and validate transactions', () async {
      NodeService nodeService = await NodeService().init(apiKey: 'test');
      int size = 0;
      while (size < 300000) {
        TransactionModel txn =
            nodeService.write(Uint8List.fromList('test contents'.codeUnits));
        size += txn.serialize().buffer.lengthInBytes;
      }
      await Future.delayed(const Duration(seconds: 5));
      List<TransactionModel> txns = nodeService.getTxnByChain();
      for (TransactionModel txn in txns) {
        expect(txn.id != null, true);
        expect(
            TransactionService.checkAuthor(txn, nodeService.publicKey), false);
        expect(TransactionService.checkIntegrity(txn), true);
        expect(TransactionService.checkInclusion(txn, txn.block!), true);
      }
    });
  });
}
