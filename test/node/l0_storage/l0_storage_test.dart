/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:tiki_sdk_dart/src/node/l0_storage/l0_storage_model_policy_req.dart';
import 'package:tiki_sdk_dart/src/node/l0_storage/l0_storage_model_policy_rsp.dart';
import 'package:tiki_sdk_dart/src/node/l0_storage/l0_storage_repository.dart';
import 'package:tiki_sdk_dart/src/utils/rsa/rsa.dart' as rsa;
import 'package:uuid/uuid.dart';

void main() {
  const String apiId = 'fb429703-f3ac-47d0-8d91-33850e89d81b';

  group('l0_storage tests', skip: apiId.isEmpty, () {
    test('Get policy', () async {
      rsa.RsaKeyPair kp = rsa.generate();
      String stringToSign = const Uuid().v4();
      String signature = base64Encode(rsa.sign(
          kp.privateKey, Uint8List.fromList(utf8.encode(stringToSign))));

      L0StorageRepository repository = L0StorageRepository(apiId);

      L0StorageModelPolicyRsp? rsp = await repository.policy(
          L0StorageModelPolicyReq(
              pubKey: kp.publicKey.encode(),
              signature: signature,
              stringToSign: stringToSign));

      expect(rsp != null, true);
      expect(rsp?.compute?.contains('key'), true);
      expect(rsp?.compute?.contains('file'), true);
      expect(rsp?.compute?.contains('content-md5'), true);
      expect(rsp?.expires?.isAfter(DateTime.now()), true);
      expect(rsp?.keyPrefix != null, true);
      expect(rsp?.maxBytes, 1048576);
      expect(rsp?.fields != null, true);
      expect(rsp?.fields?.policy != null, true);
      expect(rsp?.fields?.contentType, 'application/json');
      expect(rsp?.fields?.xAmzCredential != null, true);
      expect(rsp?.fields?.xAmzAlgorithm, 'AWS4-HMAC-SHA256');
      expect(rsp?.fields?.xAmzDate != null, true);
      expect(rsp?.fields?.xAmzSignature != null, true);
      expect(rsp?.fields?.xAmzObjectLockMode, 'GOVERNANCE');
      expect(rsp?.fields?.xAmzObjectLockRetainUntilDate != null, true);
      expect(DateTime.parse(rsp!.fields!.xAmzDate!).isBefore(DateTime.now()),
          true);
      expect(
          DateTime.parse(rsp.fields!.xAmzObjectLockRetainUntilDate!)
              .isAfter(DateTime.now()),
          true);
    });
  });
}
