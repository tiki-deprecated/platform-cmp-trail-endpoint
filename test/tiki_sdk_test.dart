
import 'package:test/test.dart';
import 'package:tiki_sdk_dart/consent/consent_model.dart';
import 'package:tiki_sdk_dart/tiki_sdk.dart';

import 'in_mem_tiki_sdk_builder.dart';

void main() {
  group('TIKI SDK tests', () {
    test('SDK initialization', () async {
      InMemTikiSdkBuilder sdkBuilder = InMemTikiSdkBuilder();
      sdkBuilder.origin('com.mytiki.sdk.dart.test');
      await sdkBuilder.build();
      expect(1, 1);
    });
    test('create ownership', () async {
      InMemTikiSdkBuilder sdkBuilder = InMemTikiSdkBuilder();
      sdkBuilder.origin('com.mytiki.sdk.dart.test');
      TikiSdk tikiSdk = await sdkBuilder.build();
      await tikiSdk
          .assignOwnership('test', TikiSdkDataTypeEnum.point, ['email']);
      expect(1, 1);
    });
    test('give and revoke consent', () async {
      InMemTikiSdkBuilder sdkBuilder = InMemTikiSdkBuilder();
      sdkBuilder.origin('com.mytiki.sdk.dart.test');
      TikiSdk tikiSdk = await sdkBuilder.build();
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
      InMemTikiSdkBuilder sdkBuilder = InMemTikiSdkBuilder();
      sdkBuilder.origin('com.mytiki.sdk.dart.test');
      TikiSdk tikiSdk = await sdkBuilder.build();
      String ownershipId = await tikiSdk
          .assignOwnership('test', TikiSdkDataTypeEnum.point, ['email']);
      await tikiSdk.modifyConsent(ownershipId, const TikiSdkDestination.all());
      await tikiSdk.applyConsent(
          'test', const TikiSdkDestination.all(), () => ok = true);
      expect(ok, true);
      await tikiSdk.modifyConsent(ownershipId, const TikiSdkDestination.all(),
          expiry: DateTime.now());
      await tikiSdk.applyConsent(
          'test', const TikiSdkDestination.all(), () => ok = true, onBlocked: (_) => ok = false);
      expect(ok, false);
    });
    test('run a function based on user consent', () async {
      bool ok = false;
      InMemTikiSdkBuilder sdkBuilder = InMemTikiSdkBuilder();
      sdkBuilder.origin('com.mytiki.sdk.dart.test');
      TikiSdk tikiSdk = await sdkBuilder.build();
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
