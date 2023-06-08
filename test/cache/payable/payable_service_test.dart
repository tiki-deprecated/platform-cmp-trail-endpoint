/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:tiki_sdk_dart/cache/license/license_service.dart';
import 'package:tiki_sdk_dart/cache/license/license_use.dart';
import 'package:tiki_sdk_dart/cache/license/license_usecase.dart';
import 'package:tiki_sdk_dart/cache/payable/payable_model.dart';
import 'package:tiki_sdk_dart/cache/payable/payable_service.dart';
import 'package:tiki_sdk_dart/cache/title/title_service.dart';
import 'package:tiki_sdk_dart/node/node_service.dart';
import 'package:tiki_sdk_dart/utils/bytes.dart';

import '../../in_mem.dart';

void main() {
  group('Payable Service Tests', () {
    test('create - Success', () async {
      NodeService nodeService = await InMemBuilders.nodeService();
      TitleService titleService =
          TitleService('com.mytiki', nodeService, nodeService.database);
      LicenseService licenseService =
          LicenseService(nodeService.database, nodeService);

      Uint8List titleId = (await titleService.create('test')).transactionId!;
      Uint8List licenseId = (await licenseService.create(
              titleId,
              [
                LicenseUse([LicenseUsecase.custom('test')])
              ],
              'terms'))
          .transactionId!;

      PayableService payableService =
          PayableService(nodeService.database, nodeService);
      PayableModel payable = await payableService.create(
          licenseId, "all the monies", "fake",
          description: "Im a description",
          reference: "ooo I got a ref",
          expiry: DateTime(2000));

      expect(Bytes.memEquals(payable.license, licenseId), true);
      expect(payable.transactionId != null, true);
      expect(payable.amount, "all the monies");
      expect(payable.type, "fake");
      expect(payable.description, "Im a description");
      expect(payable.reference, "ooo I got a ref");
      expect(payable.expiry, DateTime(2000));
    });
  });
}
