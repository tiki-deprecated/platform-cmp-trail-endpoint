/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:typed_data';

import 'package:nock/nock.dart';
import 'package:pointycastle/api.dart';
import 'package:test/test.dart';
import 'package:tiki_sdk_dart/l0/auth/auth_service.dart';
import 'package:tiki_sdk_dart/l0/storage/storage_service.dart';
import 'package:tiki_sdk_dart/utils/rsa/rsa.dart';
import 'package:tiki_sdk_dart/utils/rsa/rsa_private_key.dart';
import 'package:uuid/uuid.dart';

import '../auth/auth_nock.dart';
import 'storage_nock.dart';

void main() {
  RsaPrivateKey privateKey = Rsa.generate().privateKey;

  setUpAll(() => nock.init());
  setUp(() => nock.cleanAll());

  group('Storage Service Tests', () {
    test('Write - Success', () async {
      AuthNock authNock = AuthNock();
      final authInterceptor = authNock.interceptor;
      StorageNock storageNock = StorageNock();
      final tokenInterceptor = storageNock.tokenInterceptor;
      final uploadInterceptor = storageNock.uploadInterceptor;

      StorageService service =
          StorageService(privateKey, AuthService(authNock.clientId));
      String address =
          base64UrlEncode(Digest("SHA3-256").process(privateKey.public.bytes));
      address = address.replaceAll("=", '');

      Uint8List content = Uint8List.fromList(utf8.encode('hello world'));
      await service.write('$address/${const Uuid().v4()}', content);

      expect(authInterceptor.isDone, true);
      expect(tokenInterceptor.isDone, true);
      expect(uploadInterceptor.isDone, true);
    });

    test('Read - Success', () async {
      AuthNock authNock = AuthNock();
      final authInterceptor = authNock.interceptor;
      StorageNock storageNock = StorageNock();
      final tokenInterceptor = storageNock.tokenInterceptor;

      StorageService service =
          StorageService(privateKey, AuthService(authNock.clientId));
      String address =
          base64UrlEncode(Digest("SHA3-256").process(privateKey.public.bytes));
      address = address.replaceAll("=", '');

      Uint8List content = Uint8List.fromList(utf8.encode('hello world'));
      String path = '$address/${const Uuid().v4()}';
      String appId = storageNock.urnPrefix.split('/')[0];

      final readInterceptor = storageNock.readInterceptor(
          '$appId/$path', content,
          versionId: storageNock.firstVersion);
      final versionInterceptor = storageNock.versionInterceptor('$appId/$path');
      Uint8List? rsp = await service.read(path);

      expect(authInterceptor.isDone, true);
      expect(tokenInterceptor.isDone, true);
      expect(versionInterceptor.isDone, true);
      expect(readInterceptor.isDone, true);
      expect(rsp != null, true);
      expect(utf8.decode(rsp!), utf8.decode(content));
    });
  });
}
