import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';
import 'package:tiki_sdk_dart/consent/consent_model.dart';
import 'package:tiki_sdk_dart/node/node_service.dart';
import 'package:tiki_sdk_dart/tiki_sdk.dart';
import 'package:tiki_sdk_dart/tiki_sdk_builder.dart';

import 'in_mem_key.dart';
import 'in_mem_l0_storage.dart';

void main() {
  group('TIKI SDK tests', () {
    test('SDK initialization with api key', () async {
      String apiId = '';
      KeyStorage keyStorage = InMemKeyStorage();
      Database database = sqlite3.openInMemory();
      TikiSdkBuilderStorage sdkBuilder = TikiSdkBuilderStorage('com.mytiki');
      sdkBuilder.database = database;
      sdkBuilder.apiKey = apiId;
      sdkBuilder.keyStorage = keyStorage;
      await sdkBuilder.buildSdk();
      expect(1, 1);
    });
    test('SDK initialization with L0Storage injection', () async {
      KeyStorage keyStorage = InMemKeyStorage();
      Database database = sqlite3.openInMemory();
      TikiSdkBuilderStorage sdkBuilder = TikiSdkBuilderStorage('com.mytiki');
      sdkBuilder.database = database;
      sdkBuilder.l0Storage = InMemL0Storage();
      sdkBuilder.keyStorage = keyStorage;
      await sdkBuilder.buildSdk();
      expect(1, 1);
    });
    test('create ownership', () async {
      KeyStorage keyStorage = InMemKeyStorage();
      Database database = sqlite3.openInMemory();
      TikiSdkBuilderStorage sdkBuilder = TikiSdkBuilderStorage('com.mytiki');
      sdkBuilder.database = database;
      sdkBuilder.l0Storage = InMemL0Storage();
      sdkBuilder.keyStorage = keyStorage;
      await sdkBuilder.buildSdk();
      TikiSdk tikiSdk = sdkBuilder.tikiSdk;
      await tikiSdk
          .assignOwnership('test', TikiSdkDataTypeEnum.point, ['email']);
      expect(1, 1);
    });
    test('give and revoke consent', () async {
      KeyStorage keyStorage = InMemKeyStorage();
      Database database = sqlite3.openInMemory();
      TikiSdkBuilderStorage sdkBuilder = TikiSdkBuilderStorage('com.mytiki');
      sdkBuilder.database = database;
      sdkBuilder.l0Storage = InMemL0Storage();
      sdkBuilder.keyStorage = keyStorage;
      await sdkBuilder.buildSdk();
      TikiSdk tikiSdk = sdkBuilder.tikiSdk;
      String ownershipId = await tikiSdk
          .assignOwnership('test', TikiSdkDataTypeEnum.point, ['email']);
      await tikiSdk.modifyConsent(ownershipId, const TikiSdkDestination.all());
      ConsentModel? consentGiven = tikiSdk.getConsent('test');
      expect(consentGiven!.destination.uses[0], "*");
      expect(consentGiven.destination.paths[0], "*");
      await tikiSdk.modifyConsent(ownershipId, const TikiSdkDestination.none());
      consentGiven = tikiSdk.getConsent('test');
      expect(consentGiven!.destination.uses.isEmpty, true);
      expect(consentGiven.destination.paths.isEmpty, true);
    });
    test('expire consent', () async {
      bool ok = false;
      KeyStorage keyStorage = InMemKeyStorage();
      Database database = sqlite3.openInMemory();
      TikiSdkBuilderStorage sdkBuilder = TikiSdkBuilderStorage('com.mytiki');
      sdkBuilder.database = database;
      sdkBuilder.l0Storage = InMemL0Storage();
      sdkBuilder.keyStorage = keyStorage;
      await sdkBuilder.buildSdk();
      TikiSdk tikiSdk = sdkBuilder.tikiSdk;
      String ownershipId = await tikiSdk
          .assignOwnership('test', TikiSdkDataTypeEnum.point, ['email']);
      await tikiSdk.modifyConsent(ownershipId, const TikiSdkDestination.all());
      await tikiSdk.applyConsent(
          'test', const TikiSdkDestination.all(), () => ok = true);
      expect(ok, true);
      await tikiSdk.modifyConsent(ownershipId, const TikiSdkDestination.all(),
          expiry: DateTime.now());
      await tikiSdk.applyConsent(
          'test', const TikiSdkDestination.all(), () => ok = false);
      expect(ok, false);
    });
    test('run a function based on user consent', () async {
      bool ok = false;
      KeyStorage keyStorage = InMemKeyStorage();
      Database database = sqlite3.openInMemory();
      TikiSdkBuilderStorage sdkBuilder = TikiSdkBuilderStorage('com.mytiki');
      sdkBuilder.database = database;
      sdkBuilder.l0Storage = InMemL0Storage();
      sdkBuilder.keyStorage = keyStorage;
      await sdkBuilder.buildSdk();
      TikiSdk tikiSdk = sdkBuilder.tikiSdk;
      String ownershipId = await tikiSdk
          .assignOwnership('test', TikiSdkDataTypeEnum.point, ['email']);
      await tikiSdk.modifyConsent(ownershipId, const TikiSdkDestination.all());
      ConsentModel? consentGiven = tikiSdk.getConsent('test');
      expect(consentGiven!.destination.uses[0], "*");
      expect(consentGiven.destination.paths[0], "*");
      await tikiSdk.applyConsent(
          'test', const TikiSdkDestination.all(), () => ok = true);
      expect(ok, true);
    });
  });
}
