import 'dart:typed_data';

import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';
import 'package:tiki_sdk_dart/node/node_service.dart';
import 'package:tiki_sdk_dart/ownership/ownership_service.dart';
import 'package:tiki_sdk_dart/tiki_sdk.dart';
import 'package:tiki_sdk_dart/utils/utils.dart';

import '../in_mem_key.dart';
import '../in_mem_l0_storage.dart';

void main() {
  group('Ownership Tests', () {
    test('Repository tests. Save and get all', () {
      Database db = sqlite3.openInMemory();
      OwnershipRepository repository = OwnershipRepository(db);
      OwnershipModel ownershipModel = OwnershipModel(
          transactionId: Uint8List.fromList('random1'.codeUnits),
          source: 'tiki app',
          types: [TikiSdkDataTypeEnum.emailAddress],
          origin: 'com.mytiki.test');
      OwnershipModel ownershipModel2 = OwnershipModel(
          transactionId: Uint8List.fromList('random2'.codeUnits),
          source: 'tiki desktop',
          types: [TikiSdkDataTypeEnum.emailAddress],
          origin: 'com.mytiki.test');
      OwnershipModel ownershipModel3 = OwnershipModel(
          transactionId: Uint8List.fromList('random3'.codeUnits),
          source: 'tiki sdk',
          types: [TikiSdkDataTypeEnum.emailAddress],
          origin: 'com.mytiki.test');
      repository.save(ownershipModel);
      repository.save(ownershipModel2);
      repository.save(ownershipModel3);
      List<OwnershipModel> ownerships = repository.getAll();
      expect(ownerships.length, 3);
    });

    test('Repository tests. Save and get by source', () {
      Database db = sqlite3.openInMemory();
      OwnershipRepository repository = OwnershipRepository(db);
      OwnershipModel ownershipModel = OwnershipModel(
          transactionId: Uint8List.fromList('random1'.codeUnits),
          source: 'tiki app',
          types: [TikiSdkDataTypeEnum.emailAddress],
          origin: 'com.mytiki.test');
      OwnershipModel ownershipModel2 = OwnershipModel(
          transactionId: Uint8List.fromList('random2'.codeUnits),
          source: 'tiki desktop',
          types: [TikiSdkDataTypeEnum.emailAddress],
          origin: 'com.mytiki.test');
      OwnershipModel ownershipModel3 = OwnershipModel(
          transactionId: Uint8List.fromList('random3'.codeUnits),
          source: 'tiki sdk',
          types: [TikiSdkDataTypeEnum.emailAddress],
          origin: 'com.mytiki.test');
      repository.save(ownershipModel);
      repository.save(ownershipModel2);
      repository.save(ownershipModel3);
      OwnershipModel? ownership =
          repository.getBySource('tiki app', 'com.mytiki.test');
      expect(ownership == null, false);
      expect(
          Bytes.memEquals(ownership!.transactionId!,
              Uint8List.fromList('random1'.codeUnits)),
          true);
      ownership = repository.getBySource('tiki desktop', 'com.mytiki.test');
      expect(ownership == null, false);
      expect(
          Bytes.memEquals(ownership!.transactionId!,
              Uint8List.fromList('random2'.codeUnits)),
          true);
      ownership = repository.getBySource('tiki sdk', 'com.mytiki.test');
      expect(ownership == null, false);
      expect(
          Bytes.memEquals(ownership!.transactionId!,
              Uint8List.fromList('random3'.codeUnits)),
          true);
    });

    test('Create ownership NFT', () async {
      Database database = sqlite3.openInMemory();
      InMemKeyStorage inMemKeyStorage = InMemKeyStorage();
      InMemL0Storage inMemL0Storage = InMemL0Storage();
      NodeService nodeService =
          await NodeService().init(database, inMemKeyStorage, inMemL0Storage);
      OwnershipService ownershipService =
          OwnershipService('com.tiki.test', nodeService, database);
      Uint8List ownershipId = await ownershipService.create(
          source: 'create test', types: [TikiSdkDataTypeEnum.emailAddress]);
      expect(ownershipId.lengthInBytes == 32, true);
    });

    test('Create and retrieve ownership NFT', () async {
      Database database = sqlite3.openInMemory();
      InMemKeyStorage inMemKeyStorage = InMemKeyStorage();
      InMemL0Storage inMemL0Storage = InMemL0Storage();
      NodeService nodeService =
          await NodeService().init(database, inMemKeyStorage, inMemL0Storage);
      OwnershipService ownershipService =
          OwnershipService('com.tiki.test', nodeService, database);
      await ownershipService.create(
          source: 'create test', types: [TikiSdkDataTypeEnum.emailAddress]);
      TransactionModel transaction = TransactionModel.fromMap(
          database.select("SELECT * FROM txn LIMIT 1").first);
      expect(transaction.contents[1], 1);
      OwnershipModel retrieved =
          OwnershipModel.deserialize(transaction.contents.sublist(2));
      expect(retrieved.source, 'create test');
      expect(retrieved.origin, 'com.tiki.test');
    });

    test('Test ownership for existing NFT. Get By source.', () async {
      Database database = sqlite3.openInMemory();
      InMemKeyStorage inMemKeyStorage = InMemKeyStorage();
      InMemL0Storage inMemL0Storage = InMemL0Storage();
      NodeService nodeService =
          await NodeService().init(database, inMemKeyStorage, inMemL0Storage);
      OwnershipService ownershipService =
          OwnershipService('com.tiki.test', nodeService, database);
      Uint8List owneshipNftId = await ownershipService.create(
          source: 'create test', types: [TikiSdkDataTypeEnum.emailAddress]);
      OwnershipModel? ownershipModel =
          ownershipService.getBySource('create test');
      expect(ownershipModel != null, true);
      expect(
          Bytes.memEquals(ownershipModel!.transactionId!, owneshipNftId), true);
      expect(ownershipModel.source, 'create test');
    });
    test('Test ownership for existing NFT. Get by id.', () async {
      Database database = sqlite3.openInMemory();
      InMemKeyStorage inMemKeyStorage = InMemKeyStorage();
      InMemL0Storage inMemL0Storage = InMemL0Storage();
      NodeService nodeService =
          await NodeService().init(database, inMemKeyStorage, inMemL0Storage);
      OwnershipService ownershipService =
          OwnershipService('com.tiki.test', nodeService, database);
      Uint8List owneshipNftId = await ownershipService.create(
          source: 'create test', types: [TikiSdkDataTypeEnum.emailAddress]);
      OwnershipModel? ownershipModel = ownershipService.getById(owneshipNftId);
      expect(ownershipModel != null, true);
      expect(
          Bytes.memEquals(ownershipModel!.transactionId!, owneshipNftId), true);
      expect(ownershipModel.source, 'create test');
    });
    test('Test ownership for non-existing NFT.', () async {
      Database database = sqlite3.openInMemory();
      InMemKeyStorage inMemKeyStorage = InMemKeyStorage();
      InMemL0Storage inMemL0Storage = InMemL0Storage();
      NodeService nodeService =
          await NodeService().init(database, inMemKeyStorage, inMemL0Storage);
      OwnershipService ownershipService =
          OwnershipService('com.tiki.test', nodeService, database);
      OwnershipModel? ownershipModel = ownershipService.getById(Uint8List(1));
      expect(ownershipModel == null, true);
    });
    test('Test ownership for existing NFTs not related to the ownership',
        () async {
      Database database = sqlite3.openInMemory();
      InMemKeyStorage inMemKeyStorage = InMemKeyStorage();
      InMemL0Storage inMemL0Storage = InMemL0Storage();
      NodeService nodeService =
          await NodeService().init(database, inMemKeyStorage, inMemL0Storage);
      OwnershipService ownershipService =
          OwnershipService('com.tiki.test', nodeService, database);
      Uint8List owneshipNftId = await ownershipService.create(
          source: 'create test', types: [TikiSdkDataTypeEnum.emailAddress]);
      await ownershipService.create(
          source: 'other test', types: [TikiSdkDataTypeEnum.emailAddress]);
      OwnershipModel? ownershipModel = ownershipService.getById(owneshipNftId);
      expect(ownershipModel!.source == 'other test', false);
    });
  });
}
