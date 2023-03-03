/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:tiki_sdk_dart/cache/license/license_model.dart';
import 'package:tiki_sdk_dart/cache/license/license_service.dart';
import 'package:tiki_sdk_dart/cache/license/license_use.dart';
import 'package:tiki_sdk_dart/cache/license/license_usecase.dart';
import 'package:tiki_sdk_dart/cache/title/title_service.dart';
import 'package:tiki_sdk_dart/node/node_service.dart';
import 'package:tiki_sdk_dart/utils/bytes.dart';

import '../../in_mem_node_service_builder.dart';

void main() {
  group('License Service Tests', () {
    test('create - Success', () async {
      NodeService nodeService = await InMemNodeServiceBuilder().build();

      TitleService titleService =
          TitleService('com.mytiki', nodeService, nodeService.database);
      LicenseService licenseService =
          LicenseService(nodeService.database, nodeService);

      Uint8List titleId = (await titleService.create('test')).transactionId!;
      LicenseModel license = await licenseService.create(
          titleId,
          [
            LicenseUse([LicenseUsecase.custom('test')])
          ],
          'terms');

      expect(Bytes.memEquals(license.title, titleId), true);
      expect(license.uses.length, 1);
      expect(license.uses.elementAt(0).usecases.length, 1);
      expect(license.uses.elementAt(0).usecases.elementAt(0).value,
          LicenseUsecase.custom('test').value);
      expect(license.uses.elementAt(0).destinations, null);
      expect(license.terms, 'terms');
    });

    test('getByTitle - Success', () async {
      NodeService nodeService = await InMemNodeServiceBuilder().build();

      TitleService titleService =
          TitleService('com.mytiki', nodeService, nodeService.database);
      LicenseService licenseService =
          LicenseService(nodeService.database, nodeService);

      Uint8List titleId = (await titleService.create('test')).transactionId!;
      await licenseService.create(
          titleId,
          [
            LicenseUse([LicenseUsecase.custom('test')])
          ],
          'terms');
      await licenseService.create(
          titleId,
          [
            LicenseUse([LicenseUsecase.custom('updated')],
                destinations: ['*.mytiki.com']),
          ],
          'terms');

      LicenseModel? license = licenseService.getLatest(titleId);
      expect(license != null, true);
      expect(Bytes.memEquals(license!.title, titleId), true);
      expect(license.uses.length, 1);
      expect(license.uses.elementAt(0).usecases.length, 1);
      expect(license.uses.elementAt(0).usecases.elementAt(0).value,
          LicenseUsecase.custom('updated').value);
      expect(license.uses.elementAt(0).destinations?.length, 1);
      expect(
          license.uses.elementAt(0).destinations?.elementAt(0), '*.mytiki.com');
      expect(license.terms, 'terms');
    });
  });
}
