/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:typed_data';

import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';
import 'package:tiki_sdk_dart/cache/license/license_record.dart';
import 'package:tiki_sdk_dart/cache/license/license_repository.dart';
import 'package:tiki_sdk_dart/cache/license/license_use.dart';
import 'package:tiki_sdk_dart/cache/license/license_usecase.dart';
import 'package:tiki_sdk_dart/cache/title/title_record.dart';
import 'package:tiki_sdk_dart/cache/title/title_repository.dart';
import 'package:tiki_sdk_dart/tiki_sdk.dart';
import 'package:uuid/uuid.dart';

void main() {
  group('License Repository Tests', () {
    test('getByTitle - Success', () {
      Database db = sqlite3.openInMemory();
      TitleRepository titleRepository = TitleRepository(db);
      LicenseRepository licenseRepository = LicenseRepository(db);

      int numRecords = 3;
      Map<Uint8List, String> tidDescMap = {};

      for (int i = 0; i < numRecords; i++) {
        Uint8List tid = Bytes.utf8Encode(const Uuid().v4());
        String description = const Uuid().v4();
        tidDescMap[tid] = description;

        TitleRecord title = TitleRecord('com.mytiki.test', const Uuid().v4(),
            transactionId: tid);
        titleRepository.save(title);

        LicenseRecord license = LicenseRecord(
            title.transactionId!,
            [
              LicenseUse([LicenseUsecase.analytics()],
                  destinations: ["*.mytiki.com"])
            ],
            'terms',
            description: description);
        licenseRepository.save(license);
      }

      for (int i = 0; i < numRecords; i++) {
        LicenseRecord? license =
            licenseRepository.getByTitle(tidDescMap.keys.elementAt(i));
        expect(license == null, false);
        expect(license!.description, tidDescMap.values.elementAt(i));
        expect(license.expiry == null, true);
        expect(license.terms, 'terms');
        expect(license.uses.length, 1);
        expect(license.uses.elementAt(0).usecases.length, 1);
        expect(license.uses.elementAt(0).usecases.elementAt(0).value,
            LicenseUsecase.analytics().value);
        expect(license.uses.elementAt(0).destinations?.length, 1);
        expect(license.uses.elementAt(0).destinations?.elementAt(0),
            "*.mytiki.com");
      }
    });
  });
}
