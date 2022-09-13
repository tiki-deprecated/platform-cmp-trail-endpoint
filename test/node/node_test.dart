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
    test('create keys, backup and retrieve', () async {
      MemSecureStorageStrategy memSecureStorageStrategy =
          MemSecureStorageStrategy();
      NodeService nodeService = await NodeService().init(
          database: db,
          apiKey: apiId,
          keysSecureStorage: memSecureStorageStrategy);
      KeysService keysService = KeysService(memSecureStorageStrategy);
      KeysModel? keys = await keysService.get(base64.encode(Digest("SHA3-256")
          .process(base64.decode(nodeService.publicKey.encode()))));
      WasabiService wasabiService = WasabiService(apiId, keys!.privateKey);
      Uint8List publicKey = await wasabiService.read('public.key');
      expect(base64.encode(publicKey), keys.privateKey.public.encode());
    });
    test('create block, backup and retrieve', () async {
      MemSecureStorageStrategy memSecureStorageStrategy =
          MemSecureStorageStrategy();
      NodeService nodeService = await NodeService().init(
          blkInterval: const Duration(seconds: 5),
          database: db,
          apiKey: apiId,
          keysSecureStorage: memSecureStorageStrategy);
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
      KeysService keysService = KeysService(memSecureStorageStrategy);
      KeysModel? keys = await keysService.get(base64.encode(Digest("SHA3-256")
          .process(base64.decode(nodeService.publicKey.encode()))));
      WasabiService wasabiService = WasabiService(apiId, keys!.privateKey);
      Uint8List serializedBlk =
          await wasabiService.read(base64Url.encode(block!.id!));
      BlockModel deserializedBlock = BlockModel.deserialize(serializedBlk);
      expect(block.version, deserializedBlock.version);
      expect(memEquals(block.id!, deserializedBlock.id!), true);
      expect(
          memEquals(block.previousHash, deserializedBlock.previousHash), true);
      expect(
          memEquals(block.transactionRoot, deserializedBlock.transactionRoot),
          true);
      expect(block.transactionCount, deserializedBlock.transactionCount);
      expect(block.timestamp, deserializedBlock.timestamp);
      List<TransactionModel> txns =
          TransactionService.transactionsFromSerializedBlock(serializedBlk);
      expect(txns.length, block.transactionCount);
    });

    test('create chain', () async {
      MemSecureStorageStrategy memSecureStorageStrategy =
          MemSecureStorageStrategy();
      NodeService nodeService = await NodeService().init(
          blkInterval: const Duration(seconds: 1),
          database: db,
          apiKey: apiId,
          keysSecureStorage: memSecureStorageStrategy);
      for (int i = 0; i < 10; i++) {
        int total = Random().nextInt(200);
        List<TransactionModel> transactions = [];
        for (int j = 0; j < total; j++) {
          TransactionModel txn = nodeService
              .write(Uint8List.fromList('test contents $j$i'.codeUnits));
          transactions.add(txn);
        }
        await Future.delayed(Duration(seconds: 1));
      }
      BlockModel block = nodeService.getLastBlock()!;
      int count = 0;
      while (!memEquals(block.previousHash, Uint8List(1))) {
        List<TransactionModel> txns =
            nodeService.getTransactionsByBlockId(base64.encode(block.id!));
        expect(txns.isNotEmpty, true);
        block = nodeService.getBlockById(base64.encode(block.previousHash))!;
        count++;
      }
      expect(count > 1, true);
    });
  });
}
