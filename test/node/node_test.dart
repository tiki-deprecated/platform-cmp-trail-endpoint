import 'dart:typed_data';

import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';
import 'package:tiki_sdk_dart/node/node_service.dart';

import '../in_mem_backup.dart';
import '../in_mem_keys.dart';

void main() {
  String apiId = 'd25d2e69-89de-47aa-b5e9-5e8987cf5318';
  group('Node tests', () {
    Database db = sqlite3.openInMemory();
    test('create keys', () async {
      NodeService nodeService =
          await NodeService().init(apiId, db, InMemoryKeys(), InMemBackup());
      expect(nodeService.publicKey.encode().isNotEmpty, true);
    });
    test('create transactions', () async {
      NodeService nodeService =
          await NodeService().init(apiId, db, InMemoryKeys(), InMemBackup());
      TransactionModel txn = await nodeService
          .write(Uint8List.fromList('test contents'.codeUnits));
      expect(txn.id != null, true);
      expect(
          TransactionService.validateAuthor(txn, nodeService.publicKey), true);
      expect(TransactionService.validateIntegrity(txn), true);
    });
    test('create block by transactions count', () async {
      NodeService nodeService = await NodeService().init(
          apiId, db, InMemoryKeys(), InMemBackup(),
          blockInterval: const Duration(seconds: 20));
      int count = 0;
      List<TransactionModel> transactions = [];
      while (transactions.length < 200) {
        TransactionModel txn = await nodeService
            .write(Uint8List.fromList('test contents $count'.codeUnits));
        count++;
        transactions.add(txn);
      }
      await Future.delayed(const Duration(seconds: 5));
      BlockModel? block = nodeService.getLastBlock();
      expect(block != null, true);
    });
    test('create block by last transaction creation time', () async {
      NodeService nodeService = await NodeService().init(
          apiId, db, InMemoryKeys(), InMemBackup(),
          blockInterval: const Duration(seconds: 5));
      int size = 0;
      List<TransactionModel> transactions = [];
      while (transactions.length < 10) {
        TransactionModel txn = await nodeService
            .write(Uint8List.fromList('test contents $size'.codeUnits));
        size += txn.serialize().buffer.lengthInBytes;
        transactions.add(txn);
      }
      await Future.delayed(const Duration(seconds: 10));
      BlockModel? block = nodeService.getLastBlock();
      expect(block != null, true);
    });
  });
}
