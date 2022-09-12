import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/api.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';
import 'package:tiki_sdk_dart/src/node/block/block_model.dart';
import 'package:tiki_sdk_dart/src/node/keys/keys_model.dart';
import 'package:tiki_sdk_dart/src/node/keys/keys_service.dart';
import 'package:tiki_sdk_dart/src/node/node_service.dart';
import 'package:tiki_sdk_dart/src/node/transaction/transaction_model.dart';
import 'package:tiki_sdk_dart/src/node/transaction/transaction_service.dart';
import 'package:tiki_sdk_dart/src/node/wasabi/wasabi_service.dart';
import 'package:tiki_sdk_dart/src/utils/bytes.dart';
import 'package:tiki_sdk_dart/src/utils/mem_keys_store.dart';

void main() {
  String apiId = 'a49fe762-124e-4ced-9b88-9814d64c131b';
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
    test('create block by transactions count', () async {
      NodeService nodeService = await NodeService().init(
          blkInterval: const Duration(seconds: 20),
          database: db,
          apiKey: apiId,
          keysSecureStorage: MemSecureStorageStrategy());
      int size = 0;
      List<TransactionModel> transactions = [];
      while (transactions.length < 200) {
        TransactionModel txn = nodeService
            .write(Uint8List.fromList('test contents $size'.codeUnits));
        size += txn.serialize().buffer.lengthInBytes;
        transactions.add(txn);
      }
      await Future.delayed(const Duration(seconds: 5));
      BlockModel? block = nodeService.getLastBlock();
      expect(block != null, true);
      List<TransactionModel> txns =
          nodeService.getTransactionsByBlockId(base64.encode(block!.id!));
      expect(txns.length, transactions.length);
      for (int i = 0; i < txns.length; i++) {
        expect(txns[i].id!, transactions[i].id!);
      }
    });
    test('create block by last transaction creation time', () async {
      NodeService nodeService = await NodeService().init(
          blkInterval: const Duration(seconds: 5),
          database: db,
          apiKey: apiId,
          keysSecureStorage: MemSecureStorageStrategy());
      int size = 0;
      List<TransactionModel> transactions = [];
      while (transactions.length < 10) {
        TransactionModel txn = nodeService
            .write(Uint8List.fromList('test contents $size'.codeUnits));
        size += txn.serialize().buffer.lengthInBytes;
        transactions.add(txn);
      }
      await Future.delayed(const Duration(seconds: 10));
      BlockModel? block = nodeService.getLastBlock();
      expect(block != null, true);
      List<TransactionModel> txns =
          nodeService.getTransactionsByBlockId(base64.encode(block!.id!));
      expect(txns.length, transactions.length);
      for (int i = 0; i < txns.length; i++) {
        expect(txns[i].id!, transactions[i].id!);
      }
    });
 });
}
