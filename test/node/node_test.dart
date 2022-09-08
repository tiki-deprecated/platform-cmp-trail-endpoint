import 'dart:typed_data';

import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';
import 'package:tiki_sdk_dart/src/node/node_service.dart';
import 'package:tiki_sdk_dart/src/node/transaction/transaction_model.dart';
import 'package:tiki_sdk_dart/src/node/transaction/transaction_service.dart';

void main() {
  group('Node tests', () {
    Database db = sqlite3.openInMemory();
    test('create keys', () async {
      NodeService nodeService =
          await NodeService().init(database: db, apiKey: 'test');
      expect(nodeService.publicKey.encode().isNotEmpty, true);
    });
    test('create transactions', () async {
      NodeService nodeService =
          await NodeService().init(database: db, apiKey: 'test');
      TransactionModel txn =
          nodeService.write(Uint8List.fromList('test contents'.codeUnits));
      expect(txn.id != null, true);
      expect(TransactionService.checkAuthor(txn, nodeService.publicKey), false);
      expect(TransactionService.checkIntegrity(txn), true);
    });
    test('create block by transactions size', () async {
      NodeService nodeService =
          await NodeService().init(database: db, apiKey: 'test');
      int size = 0;
      while (size < 100000) {
        TransactionModel txn =
            nodeService.write(Uint8List.fromList('test contents'.codeUnits));
        size += txn.serialize().buffer.lengthInBytes;
      }
      await Future.delayed(const Duration(seconds: 5));
    });
    test('create block by last transaction creation time', () async {
      NodeService nodeService = await NodeService().init(
          database: db,
          blkInterval: const Duration(seconds: 20),
          apiKey: 'test');
      TransactionModel txn =
          nodeService.write(Uint8List.fromList('test contents'.codeUnits));
      await Future.delayed(const Duration(seconds: 20));

      // expect(txns.isNotEmpty, true);
      // expect(
      //     () => txns.firstWhere((txn) => txn.block == null), throwsStateError);
    });
    test('retrieve and validate transactions', () async {
      NodeService nodeService =
          await NodeService().init(database: db, apiKey: 'test');
      int size = 0;
      while (size < 300000) {
        TransactionModel txn =
            nodeService.write(Uint8List.fromList('test contents'.codeUnits));
        size += txn.serialize().buffer.lengthInBytes;
      }
      await Future.delayed(const Duration(seconds: 5));
    });
  });
}
