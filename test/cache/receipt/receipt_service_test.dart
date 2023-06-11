/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:tiki_trail/cache/license/license_service.dart';
import 'package:tiki_trail/cache/license/license_use.dart';
import 'package:tiki_trail/cache/license/license_usecase.dart';
import 'package:tiki_trail/cache/payable/payable_service.dart';
import 'package:tiki_trail/cache/receipt/receipt_model.dart';
import 'package:tiki_trail/cache/receipt/receipt_service.dart';
import 'package:tiki_trail/cache/title/title_service.dart';
import 'package:tiki_trail/node/node_service.dart';
import 'package:tiki_trail/utils/bytes.dart';

import '../../in_mem.dart';

void main() {
  group('Receipt Service Tests', () {
    test('create - Success', () async {
      NodeService nodeService = await InMemBuilders.nodeService();
      TitleService titleService =
          TitleService('com.mytiki', nodeService, nodeService.database);
      LicenseService licenseService =
          LicenseService(nodeService.database, nodeService);
      PayableService payableService =
          PayableService(nodeService.database, nodeService);

      Uint8List titleId = (await titleService.create('test')).transactionId!;
      Uint8List licenseId = (await licenseService.create(
              titleId,
              [
                LicenseUse([LicenseUsecase.custom('test')])
              ],
              'terms'))
          .transactionId!;
      Uint8List payableId = (await payableService.create(
              licenseId, "all the monies", "fake",
              description: "Im a description",
              reference: "ooo I got a ref",
              expiry: DateTime(2000)))
          .transactionId!;

      ReceiptService receiptService =
          ReceiptService(nodeService.database, nodeService);
      ReceiptModel receipt = await receiptService.create(
          payableId, "some money",
          description: "Im a description", reference: "ooo I got a ref");

      expect(Bytes.memEquals(receipt.payable, payableId), true);
      expect(receipt.transactionId != null, true);
      expect(receipt.amount, "some money");
      expect(receipt.description, "Im a description");
      expect(receipt.reference, "ooo I got a ref");
    });

    test('getAll - Success', () async {
      NodeService nodeService = await InMemBuilders.nodeService();
      TitleService titleService =
          TitleService('com.mytiki', nodeService, nodeService.database);
      LicenseService licenseService =
          LicenseService(nodeService.database, nodeService);
      PayableService payableService =
          PayableService(nodeService.database, nodeService);

      Uint8List titleId = (await titleService.create('test')).transactionId!;
      Uint8List licenseId = (await licenseService.create(
              titleId,
              [
                LicenseUse([LicenseUsecase.custom('test')])
              ],
              'terms'))
          .transactionId!;
      Uint8List payableId = (await payableService.create(
              licenseId, "all the monies", "fake",
              description: "Im a description",
              reference: "ooo I got a ref",
              expiry: DateTime(2000)))
          .transactionId!;

      ReceiptService receiptService =
          ReceiptService(nodeService.database, nodeService);
      await receiptService.create(payableId, "some money",
          description: "Im a description", reference: "ooo I got a ref");

      List<ReceiptModel> receipts = receiptService.getAll(payableId);
      expect(receipts.length, 1);
      ReceiptModel receipt = receipts.first;
      expect(Bytes.memEquals(receipt.payable, payableId), true);
      expect(receipt.transactionId != null, true);
      expect(receipt.amount, "some money");
      expect(receipt.description, "Im a description");
      expect(receipt.reference, "ooo I got a ref");
    });
  });
}
