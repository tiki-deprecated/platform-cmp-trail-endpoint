/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:test/test.dart';
import 'package:tiki_sdk_dart/tiki_sdk.dart';
import 'package:uuid/uuid.dart';

import 'in_mem_tiki_sdk_builder.dart';

void main() {
  group('TIKI SDK Guard tests', skip: true, () {
    test('expire - Success', () async {
      InMemTikiSdkBuilder sdkBuilder = InMemTikiSdkBuilder();
      sdkBuilder.origin('com.mytiki.sdk.dart.test');
      TikiSdk tikiSdk = await sdkBuilder.build();

      String ptr = const Uuid().v4();
      List<LicenseUse> uses = [
        LicenseUse([LicenseUsecase.attribution()])
      ];
      await tikiSdk.license(ptr, uses, 'terms',
          expiry: DateTime.now().subtract(const Duration(hours: 1)));
      bool pass = tikiSdk.guard(ptr, uses);
      expect(pass, false);
      await tikiSdk.license(ptr, uses, 'terms',
          expiry: DateTime.now().add(const Duration(hours: 1)));
      pass = tikiSdk.guard(ptr, uses);
      expect(pass, true);
    });

    test('usecase - Success', () async {
      InMemTikiSdkBuilder sdkBuilder = InMemTikiSdkBuilder();
      sdkBuilder.origin('com.mytiki.sdk.dart.test');
      TikiSdk tikiSdk = await sdkBuilder.build();

      String ptr = const Uuid().v4();
      List<LicenseUse> uses = [
        LicenseUse([LicenseUsecase.attribution()])
      ];
      await tikiSdk.license(ptr, uses, 'terms');
      bool pass = tikiSdk.guard(ptr, uses);
      expect(pass, true);
    });

    test('match destination - Success', () async {
      InMemTikiSdkBuilder sdkBuilder = InMemTikiSdkBuilder();
      sdkBuilder.origin('com.mytiki.sdk.dart.test');
      TikiSdk tikiSdk = await sdkBuilder.build();

      String ptr = const Uuid().v4();
      List<LicenseUse> uses = [
        LicenseUse([], destinations: ["mytiki.com"])
      ];
      await tikiSdk.license(ptr, uses, 'terms');
      bool pass = tikiSdk.guard(ptr, uses);
      expect(pass, true);
    });

    test('destination - Failure', () async {
      InMemTikiSdkBuilder sdkBuilder = InMemTikiSdkBuilder();
      sdkBuilder.origin('com.mytiki.sdk.dart.test');
      TikiSdk tikiSdk = await sdkBuilder.build();

      String ptr = const Uuid().v4();
      List<LicenseUse> uses = [
        LicenseUse([], destinations: ["mytiki.com"])
      ];
      await tikiSdk.license(ptr, uses, 'terms');
      bool pass = tikiSdk.guard(ptr, [LicenseUse([])]);
      expect(pass, false);
    });

    test('wildcard destination - Success', () async {
      InMemTikiSdkBuilder sdkBuilder = InMemTikiSdkBuilder();
      sdkBuilder.origin('com.mytiki.sdk.dart.test');
      TikiSdk tikiSdk = await sdkBuilder.build();

      String ptr = const Uuid().v4();
      List<LicenseUse> uses = [
        LicenseUse([], destinations: ["*"])
      ];
      await tikiSdk.license(ptr, uses, 'terms');
      bool pass = tikiSdk.guard(ptr, [
        LicenseUse([], destinations: ["mytiki.com"])
      ]);
      expect(pass, true);
    });

    test('wildcard destination - Failure', () async {
      InMemTikiSdkBuilder sdkBuilder = InMemTikiSdkBuilder();
      sdkBuilder.origin('com.mytiki.sdk.dart.test');
      TikiSdk tikiSdk = await sdkBuilder.build();

      String ptr = const Uuid().v4();
      List<LicenseUse> uses = [
        LicenseUse([], destinations: ["*.mytiki.com"])
      ];
      await tikiSdk.license(ptr, uses, 'terms');
      bool pass = tikiSdk.guard(ptr, [
        LicenseUse([], destinations: ["block.me"])
      ]);
      expect(pass, false);
    });

    test('NOT - Failure', () async {
      InMemTikiSdkBuilder sdkBuilder = InMemTikiSdkBuilder();
      sdkBuilder.origin('com.mytiki.sdk.dart.test');
      TikiSdk tikiSdk = await sdkBuilder.build();

      String ptr = const Uuid().v4();
      List<LicenseUse> uses = [
        LicenseUse([], destinations: ["NOT block.me"])
      ];
      await tikiSdk.license(ptr, uses, 'terms');
      bool pass = tikiSdk.guard(ptr, [
        LicenseUse([], destinations: ["block.me"])
      ]);
      expect(pass, false);
    });
  });
}
