/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/api.dart';
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
      String ptr = const Uuid().v4();
      String hashedPtr = base64.encode(
          Digest("SHA3-256").process(Uint8List.fromList(utf8.encode(ptr))));
      TitleRecord title =
          await tikiSdk.title.create(ptr, tags: [TitleTag.emailAddress()]);
      expect(title.tags.elementAt(0).value, TitleTag.emailAddress().value);
      expect(title.origin, 'com.mytiki.tiki_sdk_dart.test');
      expect(title.hashedPtr, hashedPtr);
      expect(title.description, null);
    });

    test('license - update - Success', () async {
      TikiSdk tikiSdk = await InMemBuilders.tikiSdk();
      String ptr = const Uuid().v4();
      String hashedPtr = base64.encode(
          Digest("SHA3-256").process(Uint8List.fromList(utf8.encode(ptr))));
      LicenseRecord first = await tikiSdk.license.create(
          ptr,
          [
            LicenseUse([LicenseUsecase.attribution()])
          ],
          'terms');

      expect(first.uses.elementAt(0).usecases.elementAt(0).value,
          LicenseUsecase.attribution().value);
      expect(first.terms, 'terms');
      expect(first.title.hashedPtr, hashedPtr);
      LicenseRecord second = await tikiSdk.license.create(ptr, [], 'terms');
      expect(second.uses.length, 0);
    });
  });
}
