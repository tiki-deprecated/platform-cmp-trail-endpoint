/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:io';

import 'package:test/test.dart';
import 'package:tiki_sdk_dart/src/node/l0_storage/l0_storage_model_policy_rsp.dart';
import 'package:tiki_sdk_dart/src/node/l0_storage/l0_storage_service.dart';
import 'package:tiki_sdk_dart/src/utils/rsa/rsa.dart' as rsa;
import 'package:uuid/uuid.dart';

void main() {
  const String apiId = '';

  group('l0_storage tests', skip: apiId.isEmpty, () {
    test('Get policy', () async {
      rsa.RsaKeyPair kp = rsa.generate();

      L0StorageService service = L0StorageService(apiId, kp.privateKey);
      L0StorageModelPolicyRsp rsp = await service.policy();

      expect(rsp.compute?.contains('key'), true);
      expect(rsp.compute?.contains('file'), true);
      expect(rsp.compute?.contains('content-md5'), true);
      expect(rsp.expires?.isAfter(DateTime.now()), true);
      expect(rsp.keyPrefix != null, true);
      expect(rsp.maxBytes, 1048576);
      expect(rsp.fields != null, true);
      expect(rsp.fields?['policy'] != null, true);
      expect(rsp.fields?['content-type'], 'application/octet-stream');
      expect(rsp.fields?['x-amz-credential'] != null, true);
      expect(rsp.fields?['x-amz-algorithm'], 'AWS4-HMAC-SHA256');
      expect(rsp.fields?['x-amz-date'] != null, true);
      expect(rsp.fields?['x-amz-signature'] != null, true);
      expect(rsp.fields?['x-amz-object-lock-mode'], 'GOVERNANCE');
      expect(rsp.fields?['x-amz-object-lock-retain-until-date'] != null, true);
      expect(
          DateTime.parse(rsp.fields!['x-amz-date']!).isBefore(DateTime.now()),
          true);
      expect(
          DateTime.parse(rsp.fields!['x-amz-object-lock-retain-until-date']!)
              .isAfter(DateTime.now()),
          true);
    });

    test('Bad API Id', () async {
      rsa.RsaKeyPair kp = rsa.generate();

      L0StorageService service =
          L0StorageService(const Uuid().v4(), kp.privateKey);

      expect(() async => await service.policy(), throwsA(isA<HttpException>()));
    });
  });
}
