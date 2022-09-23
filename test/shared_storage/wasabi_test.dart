/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:tiki_sdk_dart/node/node_service.dart';
import 'package:tiki_sdk_dart/shared_storage/policy/policy_model_rsp.dart';
import 'package:tiki_sdk_dart/shared_storage/policy/policy_service.dart';
import 'package:tiki_sdk_dart/shared_storage/wasabi/wasabi_service.dart';
import 'package:tiki_sdk_dart/utils/rsa/rsa.dart' as rsa;
import 'package:tiki_sdk_dart/utils/utils.dart';

void main() async {
  const String apiId = '';
  const bool runTests = false;

  group('Wasabi Tests', skip: apiId.isNotEmpty && !runTests, () {
    test('Write/Read - Success', () async {
      rsa.RsaKeyPair kp = Rsa.generate();

      String testFile =
          '{"Test":["OK","OK","OK","OK","OK","OK","OK","OK","OK","OK","OK","OK","OK","OK","OK","OK","OK","OK","OK","OK","OK","OK","OK","OK","OK","OK","OK","OK","OK","OK","OK","OK"]}';

      PolicyService l0storageService = PolicyService(apiId, kp.privateKey);
      PolicyModelRsp policy = await l0storageService.request();

      WasabiService service = WasabiService();
      await service.write('${policy.keyPrefix}test.block',
          Uint8List.fromList(utf8.encode(testFile)),
          fields: policy.fields!);
      Uint8List rsp = await service.read('${policy.keyPrefix}test.block');

      expect(testFile, utf8.decode(rsp));
    });
  });
}
