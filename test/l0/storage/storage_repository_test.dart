/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:typed_data';

import 'package:nock/nock.dart';
import 'package:test/test.dart';
import 'package:tiki_trail/key.dart';
import 'package:tiki_trail/l0/storage/storage_model_token_req.dart';
import 'package:tiki_trail/l0/storage/storage_model_token_rsp.dart';
import 'package:tiki_trail/l0/storage/storage_model_upload.dart';
import 'package:tiki_trail/l0/storage/storage_repository.dart';
import 'package:uuid/uuid.dart';

import '../../fixtures/idp.dart' as idp_fixture;
import '../../fixtures/storage_nock.dart';

Future<void> main() async {
  Key key = await idp_fixture.key;

  setUpAll(() => nock.init());
  setUp(() => nock.cleanAll());

  group('Storage Repository Tests', () {
    test('Token - Success', () async {
      StorageNock storageNock = StorageNock();
      final tokenInterceptor = storageNock.tokenInterceptor;

      StorageRepository repository = StorageRepository();
      String stringToSign = const Uuid().v4();

      Uint8List signature = await idp_fixture.idp
          .sign(key.id, Uint8List.fromList(utf8.encode(stringToSign)));

      StorageModelTokenReq req = StorageModelTokenReq(
          pubKey: await idp_fixture.idp.export(key.id),
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
      Uint8List signature = await idp_fixture.idp
          .sign(key.id, Uint8List.fromList(utf8.encode(stringToSign)));
      StorageModelTokenReq req = StorageModelTokenReq(
          pubKey: await idp_fixture.idp.export(key.id),
          signature: base64Encode(signature),
          stringToSign: stringToSign);

      StorageModelTokenRsp rsp = await repository.token('authorization', req);
      Uint8List content = Uint8List.fromList(utf8.encode('hello world'));
      String uploadKey = '${rsp.urnPrefix}${const Uuid().v4()}';

      final uploadInterceptor = storageNock.uploadInterceptor;
      final readInterceptor = storageNock.readInterceptor(uploadKey, content);

      await repository.upload(
          rsp.token, StorageModelUpload(key: uploadKey, content: content));
      Uint8List saved = await repository.get(uploadKey);

      expect(tokenInterceptor.isDone, true);
      expect(uploadInterceptor.isDone, true);
      expect(readInterceptor.isDone, true);
      expect(content, saved);
    });
  });
}
