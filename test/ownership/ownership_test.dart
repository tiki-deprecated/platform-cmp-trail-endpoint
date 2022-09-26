import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';
import 'package:tiki_sdk_dart/ownership/ownership_model.dart';
import 'package:tiki_sdk_dart/ownership/ownership_repository.dart';
import 'package:tiki_sdk_dart/tiki_sdk.dart';

void main() {
  group('Ownership Tests', () {
    test('Repository tests. Save and get all', () {
      Database db = sqlite3.openInMemory();
      OwnershipRepository repository = OwnershipRepository(db);
      OwnershipModel ownershipModel = OwnershipModel(
          transactionId: 'random1',
          source: 'tiki app',
          types: [TikiSdkDataTypeEnum.emailAddress],
          origin: 'com.mytiki.test');
      OwnershipModel ownershipModel2 = OwnershipModel(
          transactionId: 'random2',
          source: 'tiki desktop',
          types: [TikiSdkDataTypeEnum.emailAddress],
          origin: 'com.mytiki.test');
      OwnershipModel ownershipModel3 = OwnershipModel(
          transactionId: 'random3',
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
          transactionId: 'random1',
          source: 'tiki app',
          types: [TikiSdkDataTypeEnum.emailAddress],
          origin: 'com.mytiki.test');
      OwnershipModel ownershipModel2 = OwnershipModel(
          transactionId: 'random2',
          source: 'tiki desktop',
          types: [TikiSdkDataTypeEnum.emailAddress],
          origin: 'com.mytiki.test');
      OwnershipModel ownershipModel3 = OwnershipModel(
          transactionId: 'random3',
          source: 'tiki sdk',
          types: [TikiSdkDataTypeEnum.emailAddress],
          origin: 'com.mytiki.test');
      repository.save(ownershipModel);
      repository.save(ownershipModel2);
      repository.save(ownershipModel3);
      OwnershipModel? ownership = repository.getBySource('tiki app', 'com.mytiki.test');
      expect(ownership == null, false);
      expect(ownership!.transactionId, 'random1');
      ownership = repository.getBySource('tiki desktop', 'com.mytiki.test');
      expect(ownership == null, false);
      expect(ownership!.transactionId, 'random2');
      ownership = repository.getBySource('tiki sdk', 'com.mytiki.test');
      expect(ownership == null, false);
      expect(ownership!.transactionId, 'random3');
    });
  });
}
