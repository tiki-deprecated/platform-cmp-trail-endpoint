/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:typed_data';

import 'package:nock/nock.dart';
import 'package:test/test.dart';
import 'package:tiki_sdk_dart/l0/storage/storage_model_token_req.dart';
import 'package:tiki_sdk_dart/l0/storage/storage_model_token_rsp.dart';
import 'package:tiki_sdk_dart/l0/storage/storage_model_upload.dart';
import 'package:tiki_sdk_dart/l0/storage/storage_repository.dart';
import 'package:tiki_sdk_dart/utils/rsa/rsa.dart';
import 'package:tiki_sdk_dart/utils/rsa/rsa_private_key.dart';
import 'package:uuid/uuid.dart';

import 'storage_nock.dart';

void main() {
  RsaPrivateKey privateKey = Rsa.generate().privateKey;

  setUpAll(() => nock.init());
  setUp(() => nock.cleanAll());

  group('Storage Repository Tests', () {
    test('Token - Success', () async {
      StorageNock storageNock = StorageNock();
      final tokenInterceptor = storageNock.tokenInterceptor;

      StorageRepository repository = StorageRepository();
      String stringToSign = const Uuid().v4();
      Uint8List signature =
          Rsa.sign(privateKey, Uint8List.fromList(utf8.encode(stringToSign)));
      StorageModelTokenReq req = StorageModelTokenReq(
          pubKey: privateKey.public.encode(),
          signature: base64Encode(signature),
          stringToSign: stringToSign);
      StorageModelTokenRsp rsp = await repository.token('authorization', req);

      expect(tokenInterceptor.isDone, true);
      expect(rsp.urnPrefix, storageNock.urnPrefix);
      expect(rsp.token, storageNock.token);
      expect(rsp.expires?.isAfter(DateTime.now()), true);
      expect(rsp.type, 'Bearer');
    });

    test('Upload - Success', () async {
      StorageNock storageNock = StorageNock();
      final tokenInterceptor = storageNock.tokenInterceptor;

      StorageRepository repository = StorageRepository();
      String stringToSign = const Uuid().v4();
      Uint8List signature =
          Rsa.sign(privateKey, Uint8List.fromList(utf8.encode(stringToSign)));
      StorageModelTokenReq req = StorageModelTokenReq(
          pubKey: privateKey.public.encode(),
          signature: base64Encode(signature),
          stringToSign: stringToSign);

      StorageModelTokenRsp rsp = await repository.token('authorization', req);
      Uint8List content = Uint8List.fromList(utf8.encode('hello world'));
      String key = '${rsp.urnPrefix}${const Uuid().v4()}';

      final uploadInterceptor = storageNock.uploadInterceptor;
      final readInterceptor = storageNock.readInterceptor(key, content);

      await repository.upload(
          rsp.token, StorageModelUpload(key: key, content: content));
      Uint8List saved = await repository.get(key);

      expect(tokenInterceptor.isDone, true);
      expect(uploadInterceptor.isDone, true);
      expect(readInterceptor.isDone, true);
      expect(content, saved);
    });
  });
}
