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
          await tikiSdk.title(ptr, tags: [TitleTag.emailAddress()]);
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
      LicenseRecord first = await tikiSdk.license(
          ptr,
          [
            LicenseUse([LicenseUsecase.attribution()])
          ],
          'terms');

      expect(first.uses.elementAt(0).usecases.elementAt(0).value,
          LicenseUsecase.attribution().value);
      expect(first.terms, 'terms');
      expect(first.title.hashedPtr, hashedPtr);
      LicenseRecord second = await tikiSdk.license(ptr, [], 'terms');
      expect(second.uses.length, 0);
    });

    test('all - method - success', () async {
      TikiSdk tikiSdk = await InMemBuilders.tikiSdk();
      String ptr = const Uuid().v4();
      String origin = 'com.myco.myapp';
      List<TitleTag> tags = [TitleTag.contacts(), TitleTag.audio()];
      String description = 'New Description';
      await tikiSdk.title(ptr,
          origin: origin, tags: tags, description: description);
      String terms = "This is a new term";
      List<LicenseUse> uses = [
        LicenseUse([LicenseUsecase.aiTraining()]),
        LicenseUse([LicenseUsecase.analytics()]),
      ];
      await tikiSdk.license(ptr, uses, terms,
          origin: origin, expiry: DateTime(1));
      await tikiSdk.license(ptr, uses, terms,
          origin: origin, expiry: DateTime(2));
      List<LicenseRecord> record = tikiSdk.all(ptr, origin: origin);

      /// Case 1 : Retrieve all licenses for a valid title
      expect(record.length, 2);
      expect(record.elementAt(0).expiry, DateTime(2));
      expect(record.elementAt(0).terms, terms);
      expect(record.elementAt(1).expiry, DateTime(1));
      expect(record.elementAt(1).terms, terms);
      expect(record.elementAt(0).uses.elementAt(0).usecases.elementAt(0).value,
          uses.elementAt(0).usecases.elementAt(0).value);
      expect(record.elementAt(0).uses.elementAt(1).usecases.elementAt(0).value,
          uses.elementAt(1).usecases.elementAt(0).value);

      /// Case 2: Retrieve all licenses for an invalid title
      String invalidPTR = "This is an invalid ptr";
      List<LicenseRecord> invalidRecord =
          tikiSdk.all(invalidPTR, origin: origin);
      expect(invalidRecord, []);

      /// Case 3 : Retrieve all licenses for a title with no licenses
      String ptr2 = const Uuid().v4();
      String origin2 = 'com.myco.myapp';
      List<TitleTag> tags2 = [TitleTag.contacts(), TitleTag.audio()];
      String description2 = 'New Description';
      await tikiSdk.title(ptr2,
          origin: origin2, tags: tags2, description: description2);
      List<LicenseRecord> record2 = tikiSdk.all(ptr2, origin: origin2);
      expect(record2, []);
    });
  });
}
