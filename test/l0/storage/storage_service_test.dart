/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:typed_data';

import 'package:nock/nock.dart';
import 'package:test/test.dart';
import 'package:tiki_trail/key.dart';
import 'package:tiki_trail/l0/storage/storage_service.dart';
import 'package:uuid/uuid.dart';

import '../../fixtures/auth_nock.dart';
import '../../fixtures/idp.dart' as idp_fixture;
import '../../fixtures/storage_nock.dart';

Future<void> main() async {
  Key key = await idp_fixture.key;

  setUpAll(() => nock.init());
  setUp(() => nock.cleanAll());

  group('Storage Service Tests', skip: true, () {
    test('Write - Success', () async {
      AuthNock authNock = AuthNock();
      final authInterceptor = authNock.interceptor;
      StorageNock storageNock = StorageNock();
      final tokenInterceptor = storageNock.tokenInterceptor;
      final uploadInterceptor = storageNock.uploadInterceptor;

      StorageService service = StorageService(key.id, idp_fixture.idp);
      String address = key.address;
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

      StorageService service = StorageService(key.id, idp_fixture.idp);
      String address = key.address;
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
