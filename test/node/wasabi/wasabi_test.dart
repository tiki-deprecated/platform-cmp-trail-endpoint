/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:tiki_sdk_dart/node/node_service.dart';
import 'package:tiki_sdk_dart/node/wasabi/wasabi_service.dart';
import 'package:tiki_sdk_dart/utils/rsa/rsa.dart' as rsa;
import 'package:tiki_sdk_dart/utils/utils.dart';

void main() async {
  const String apiId = 'd25d2e69-89de-47aa-b5e9-5e8987cf5318';
  const bool runTests = false;

  group('l0_storage tests', skip: apiId.isNotEmpty && !runTests, () {
    test('Upload - Read', () async {
      rsa.RsaKeyPair kp = UtilsRsa.generate();

      String testFile =
          '{"Test":["OK","OK","OK","OK","OK","OK","OK","OK","OK","OK","OK","OK","OK","OK","OK","OK","OK","OK","OK","OK","OK","OK","OK","OK","OK","OK","OK","OK","OK","OK","OK","OK"]}';

      L0StorageService l0storageService =
          L0StorageService(apiId, kp.privateKey);
      L0StorageModelPolicyRsp policy = await l0storageService.policy();

      WasabiService service = WasabiService();
      await service.write('${policy.keyPrefix}test.block',
          Uint8List.fromList(utf8.encode(testFile)),
          fields: policy.fields!);

      Uint8List rsp = await service.read('${policy.keyPrefix}test.block');

      expect(testFile, utf8.decode(rsp));
    });
  });
}
