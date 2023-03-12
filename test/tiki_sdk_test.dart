/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:test/test.dart';
import 'package:tiki_sdk_dart/tiki_sdk.dart';
import 'package:uuid/uuid.dart';

import 'in_mem.dart';

void main() {
  group('TIKI SDK License tests', () {
    test('construct - Success', () async {
      await InMemBuilders.tikiSdk();
      expect(1, 1);
    });

    test('title - Success', () async {
      TikiSdk tikiSdk = await InMemBuilders.tikiSdk();
      await tikiSdk.title(const Uuid().v4(), tags: [TitleTag.emailAddress()]);
      expect(1, 1);
    });

    test('license - update - Success', () async {
      TikiSdk tikiSdk = await InMemBuilders.tikiSdk();
      String ptr = const Uuid().v4();
      LicenseRecord first = await tikiSdk.license(
          ptr,
          [
            LicenseUse([LicenseUsecase.attribution()])
          ],
          'terms');

      expect(first.uses.elementAt(0).usecases.elementAt(0).value,
          LicenseUsecase.attribution().value);
      LicenseRecord second = await tikiSdk.license(ptr, [], 'terms');
      expect(second.uses.length, 0);
    });
  });
}
