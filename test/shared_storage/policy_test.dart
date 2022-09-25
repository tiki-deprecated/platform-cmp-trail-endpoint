/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:io';

import 'package:test/test.dart';
import 'package:tiki_sdk_dart/shared_storage/policy/policy_model_rsp.dart';
import 'package:tiki_sdk_dart/shared_storage/policy/policy_service.dart';
import 'package:tiki_sdk_dart/utils/rsa/rsa.dart';
import 'package:tiki_sdk_dart/utils/utils.dart';
import 'package:uuid/uuid.dart';

void main() {
  const String apiId = '';

  group('Policy Tests', skip: apiId.isEmpty, () {
    test('Request - Success', () async {
      RsaKeyPair kp = Rsa.generate();
      PolicyService service = PolicyService(apiId, kp.privateKey);
      PolicyModelRsp rsp = await service.request();

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

    test('Request - Bad API Id - Failure', () async {
      RsaKeyPair kp = Rsa.generate();
      PolicyService service = PolicyService(const Uuid().v4(), kp.privateKey);

      expect(
          () async => await service.request(), throwsA(isA<HttpException>()));
    });
  });
}
