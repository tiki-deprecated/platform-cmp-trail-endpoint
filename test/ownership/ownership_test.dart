import 'dart:typed_data';

import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';
import 'package:tiki_sdk_dart/ownership/ownership_model.dart';
import 'package:tiki_sdk_dart/ownership/ownership_repository.dart';
import 'package:tiki_sdk_dart/tiki_sdk.dart';
import 'package:tiki_sdk_dart/utils/utils.dart';

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
      OwnershipModel? ownership = repository.getBySource('tiki app', 'com.mytiki.test');
      expect(ownership == null, false);
      expect(Bytes.memEquals(ownership!.transactionId!, Uint8List.fromList('random1'.codeUnits)), true);
      ownership = repository.getBySource('tiki desktop', 'com.mytiki.test');
      expect(ownership == null, false);
      expect(Bytes.memEquals(ownership!.transactionId!, Uint8List.fromList('random2'.codeUnits)), true);
      ownership = repository.getBySource('tiki sdk', 'com.mytiki.test');
      expect(ownership == null, false);
      expect(Bytes.memEquals(ownership!.transactionId!, Uint8List.fromList('random3'.codeUnits)), true);
    });
  });
}
