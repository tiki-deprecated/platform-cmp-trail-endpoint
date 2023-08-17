/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';
import 'package:tiki_trail/cache/license/license_model.dart';
import 'package:tiki_trail/cache/license/license_repository.dart';
import 'package:tiki_trail/cache/license/license_use.dart';
import 'package:tiki_trail/cache/license/license_usecase.dart';
import 'package:tiki_trail/cache/payable/payable_model.dart';
import 'package:tiki_trail/cache/payable/payable_repository.dart';
import 'package:tiki_trail/cache/title/title_model.dart';
import 'package:tiki_trail/cache/title/title_repository.dart';
import 'package:tiki_trail/node/transaction/transaction_repository.dart';
import 'package:tiki_trail/utils/bytes.dart';
import 'package:uuid/uuid.dart';

void main() {
  group('Payable Repository Tests', () {
    test('getById - Success', () {
      Database db = sqlite3.openInMemory();
      TransactionRepository(db);
      TitleRepository titleRepository = TitleRepository(db);
      LicenseRepository licenseRepository = LicenseRepository(db);
      PayableRepository payableRepository = PayableRepository(db);

      TitleModel title = TitleModel('com.mytiki.test', const Uuid().v4(),
          transactionId: Bytes.utf8Encode(const Uuid().v4()));
      titleRepository.save(title);
      LicenseModel license = LicenseModel(
          title.transactionId!,
          [
            LicenseUse([LicenseUsecase.analytics()],
                destinations: ["*.mytiki.com"])
          ],
          'terms',
          transactionId: Bytes.utf8Encode(const Uuid().v4()));
      licenseRepository.save(license);

      PayableModel payable = PayableModel(
          license.transactionId!, "all the monies", "fake",
          description: "Im a description",
          reference: "ooo I got a ref",
          expiry: DateTime(2000),
          transactionId: Bytes.utf8Encode(const Uuid().v4()));
      payableRepository.save(payable);

      PayableModel? found = payableRepository.getById(payable.transactionId!);
      expect(found != null, true);
      expect(found!.license, license.transactionId);
      expect(found.amount, "all the monies");
      expect(found.type, "fake");
      expect(found.description, "Im a description");
      expect(found.reference, "ooo I got a ref");
      expect(found.expiry, DateTime(2000));
    });
  });
}
