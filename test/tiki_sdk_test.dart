import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';
import 'package:tiki_sdk_dart/consent/consent_model.dart';
import 'package:tiki_sdk_dart/node/l0_storage.dart';
import 'package:tiki_sdk_dart/node/node_service.dart';
import 'package:tiki_sdk_dart/tiki_sdk.dart';

import 'in_mem_key.dart';
import 'in_mem_l0_storage.dart';

void main() {
  group('TIKI SDK tests', () {
    test('SDK initialization', () async {
      L0Storage l0storage = InMemL0Storage();
      KeyStorage keyStorage = InMemKeyStorage();
      Database database = sqlite3.openInMemory();
      await TikiSdk().init('com.mytiki.test', database, keyStorage, l0storage);
      expect(1, 1);
    });
    test('create ownership', () async {
      L0Storage l0storage = InMemL0Storage();
      KeyStorage keyStorage = InMemKeyStorage();
      Database database = sqlite3.openInMemory();
      TikiSdk tikiSdk = await TikiSdk()
          .init('com.mytiki.test', database, keyStorage, l0storage);
      await tikiSdk
          .assignOwnership('test', TikiSdkDataTypeEnum.point, ['email']);
      expect(1, 1);
    });
    test('give and revoke consent', () async {
      L0Storage l0storage = InMemL0Storage();
      KeyStorage keyStorage = InMemKeyStorage();
      Database database = sqlite3.openInMemory();
      TikiSdk tikiSdk = await TikiSdk()
          .init('com.mytiki.test', database, keyStorage, l0storage);
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
    test('run a function based on user consent', () async {
      bool ok = false;
      L0Storage l0storage = InMemL0Storage();
      KeyStorage keyStorage = InMemKeyStorage();
      Database database = sqlite3.openInMemory();
      TikiSdk tikiSdk = await TikiSdk()
          .init('com.mytiki.test', database, keyStorage, l0storage);
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
