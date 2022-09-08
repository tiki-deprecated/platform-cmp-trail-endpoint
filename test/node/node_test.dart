import 'dart:typed_data';

import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';
import 'package:tiki_sdk_dart/src/node/node_service.dart';
import 'package:tiki_sdk_dart/src/node/transaction/transaction_model.dart';
import 'package:tiki_sdk_dart/src/node/transaction/transaction_service.dart';
import 'package:tiki_sdk_dart/src/utils/mem_keys_store.dart';

void main() {
  group('Node tests', () {
    Database db = sqlite3.openInMemory();
    test('create keys', () async {
      NodeService nodeService = await NodeService().init(
          database: db,
          apiKey: 'test',
          keysSecureStorage: MemSecureStorageStrategy());
      expect(nodeService.publicKey.encode().isNotEmpty, true);
    });
    test('create transactions', () async {
      NodeService nodeService = await NodeService().init(
          database: db,
          apiKey: 'test',
          keysSecureStorage: MemSecureStorageStrategy());
      TransactionModel txn =
          nodeService.write(Uint8List.fromList('test contents'.codeUnits));
      expect(txn.id != null, true);
      expect(
          TransactionService.validateAuthor(txn, nodeService.publicKey), true);
      expect(TransactionService.validateIntegrity(txn), true);
    });
    test('create block by transactions size', () async {
      NodeService nodeService = await NodeService().init(
          blkInterval: const Duration(seconds: 20),
          database: db,
          apiKey: 'test',
          keysSecureStorage: MemSecureStorageStrategy());
      int size = 0;
      while (size < 100000) {
        TransactionModel txn = nodeService
            .write(Uint8List.fromList('test contents $size'.codeUnits));
        size += txn.serialize().buffer.lengthInBytes;
      }
      await Future.delayed(const Duration(seconds: 5));
    });
    test('create block by last transaction creation time', () async {});
    test('retrieve and validate transactions', () async {
      NodeService nodeService = await NodeService().init(
          blkInterval: const Duration(seconds: 20),
          database: db,
          apiKey: 'test',
          keysSecureStorage: MemSecureStorageStrategy());
      int size = 0;
      while (size < 300000) {
        TransactionModel txn = nodeService
            .write(Uint8List.fromList('test contents $size'.codeUnits));
        size += txn.serialize().buffer.lengthInBytes;
      }
      await Future.delayed(const Duration(seconds: 5));
    });
  });
}
