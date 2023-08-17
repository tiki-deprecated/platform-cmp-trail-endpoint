/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';
import 'package:tiki_trail/cache/license/license_model.dart';
import 'package:tiki_trail/cache/license/license_repository.dart';
import 'package:tiki_trail/cache/license/license_service.dart';
import 'package:tiki_trail/cache/license/license_use.dart';
import 'package:tiki_trail/cache/license/license_usecase.dart';
import 'package:tiki_trail/cache/title/title_model.dart';
import 'package:tiki_trail/cache/title/title_repository.dart';
import 'package:tiki_trail/cache/title/title_service.dart';
import 'package:tiki_trail/node/node_service.dart';
import 'package:tiki_trail/node/transaction/transaction_repository.dart';
import 'package:tiki_trail/utils/bytes.dart';
import 'package:uuid/uuid.dart';

import '../../fixtures/in_mem.dart';

void main() {
  group('License Repository Tests', () {
    test('getByTitle - Success', () {
      Database db = sqlite3.openInMemory();
      TransactionRepository(db);
      TitleRepository titleRepository = TitleRepository(db);
      LicenseRepository licenseRepository = LicenseRepository(db);

      TitleModel title = TitleModel('com.mytiki.test', const Uuid().v4(),
          transactionId: Bytes.utf8Encode(const Uuid().v4()));
      titleRepository.save(title);
      int numRecords = 3;
      for (int i = 0; i < numRecords; i++) {
        LicenseModel license = LicenseModel(
            title.transactionId!,
            [
              LicenseUse([LicenseUsecase.analytics()],
                  destinations: ["*.mytiki.com"])
            ],
            'terms',
            description: 'license: $i');
        licenseRepository.save(license);
      }

      List<LicenseModel> found =
          licenseRepository.getAllByTitle(title.transactionId!);
      expect(found.length, numRecords);
      for (int i = 0; i < numRecords; i++) {
        LicenseModel license = found.elementAt(i);
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

    test('getLatestByTitle - Success', () async {
      NodeService nodeService = await InMemBuilders.nodeService();
      TitleService titleService =
          TitleService('com.tiki.test', nodeService.database, nodeService);
      LicenseService licenseService =
          LicenseService(nodeService.database, nodeService);
      LicenseRepository licenseRepository =
          LicenseRepository(nodeService.database);

      TitleModel title = await titleService.create('ptr');
      int numRecords = 10;
      for (int i = 0; i < numRecords; i++) {
        await licenseService.create(title.transactionId!, [], 'record: $i');
      }

      await Future.delayed(const Duration(seconds: 5));

      LicenseModel? license =
          licenseRepository.getLatestByTitle(title.transactionId!);
      expect(license?.terms, 'record: 9');
    });
  });
}
