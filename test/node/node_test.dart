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
    test('create block by last transaction creation time', () async {});
   });
}
