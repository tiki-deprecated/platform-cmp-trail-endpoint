/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/api.dart';
import 'package:test/test.dart';
import 'package:tiki_trail/tiki_trail.dart';
import 'package:uuid/uuid.dart';

import 'fixtures/in_mem.dart';

void main() {
  group('TIKI Trail License tests', () {
    test('construct - Success', () async {
      await InMemBuilders.tikiTrail();
      expect(1, 1);
    });

    test('title - Success', () async {
      TikiTrail trail = await InMemBuilders.tikiTrail();
      String ptr = const Uuid().v4();
      String hashedPtr = base64.encode(
          Digest("SHA3-256").process(Uint8List.fromList(utf8.encode(ptr))));
      TitleRecord title =
          await trail.title.create(ptr, tags: [TitleTag.emailAddress()]);
      expect(title.tags.elementAt(0).value, TitleTag.emailAddress().value);
      expect(title.origin, 'com.mytiki.tiki_trail.test');
      expect(title.hashedPtr, hashedPtr);
      expect(title.description, null);
    });

    test('license - update - Success', () async {
      TikiTrail trail = await InMemBuilders.tikiTrail();
      String ptr = const Uuid().v4();
      String hashedPtr = base64.encode(
          Digest("SHA3-256").process(Uint8List.fromList(utf8.encode(ptr))));
      TitleRecord title =
          await trail.title.create(ptr, tags: [TitleTag.emailAddress()]);
      LicenseRecord first = await trail.license.create(
          title,
          [
            LicenseUse([LicenseUsecase.attribution()])
          ],
          'terms');

      expect(first.uses.elementAt(0).usecases.elementAt(0).value,
          LicenseUsecase.attribution().value);
      expect(first.terms, 'terms');
      expect(first.title.hashedPtr, hashedPtr);
      LicenseRecord second = await trail.license.create(title, [], 'terms');
      expect(second.uses.length, 0);
    });
  });
}
