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
import 'package:tiki_trail/cache/receipt/receipt_model.dart';
import 'package:tiki_trail/cache/receipt/receipt_repository.dart';
import 'package:tiki_trail/cache/title/title_model.dart';
import 'package:tiki_trail/cache/title/title_repository.dart';
import 'package:tiki_trail/utils/bytes.dart';
import 'package:uuid/uuid.dart';

void main() {
  group('Receipt Repository Tests', () {
    test('getById - Success', () {
      Database db = sqlite3.openInMemory();
      TitleRepository titleRepository = TitleRepository(db);
      LicenseRepository licenseRepository = LicenseRepository(db);
      PayableRepository payableRepository = PayableRepository(db);
      ReceiptRepository receiptRepository = ReceiptRepository(db);

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

      ReceiptModel receipt = ReceiptModel(payable.transactionId!, "some money",
          description: "Im a description",
          reference: "ooo I got a ref",
          transactionId: Bytes.utf8Encode(const Uuid().v4()));
      receiptRepository.save(receipt);

      ReceiptModel? found = receiptRepository.getById(receipt.transactionId!);
      expect(found != null, true);
      expect(found!.payable, payable.transactionId);
      expect(found.amount, "some money");
      expect(found.description, "Im a description");
      expect(found.reference, "ooo I got a ref");
    });
  });
}
