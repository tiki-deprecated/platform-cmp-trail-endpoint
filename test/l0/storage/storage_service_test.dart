/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/api.dart';
import 'package:test/test.dart';
import 'package:tiki_sdk_dart/l0/auth/auth_service.dart';
import 'package:tiki_sdk_dart/l0/storage/storage_service.dart';
import 'package:tiki_sdk_dart/utils/rsa/rsa.dart';
import 'package:uuid/uuid.dart';

void main() {
  const String publishingId = '2b8de004-cbe0-4bd5-bda6-b266d54f5c90';
  RsaPrivateKey privateKey = Rsa.generate().privateKey;

  group('Storage Service Tests', skip: publishingId.isEmpty, () {
    test('Write - Success', () async {
      StorageService service =
          StorageService(privateKey, AuthService(publishingId));
      String address =
          base64UrlEncode(Digest("SHA3-256").process(privateKey.public.bytes));
      address = address.replaceAll("=", '');

      Uint8List content = Uint8List.fromList(utf8.encode('hello world'));
      await service.write('$address/${const Uuid().v4()}', content);
    });

    test('Read - Success', () async {
      StorageService service =
          StorageService(privateKey, AuthService(publishingId));
      String address =
          base64UrlEncode(Digest("SHA3-256").process(privateKey.public.bytes));
      address = address.replaceAll("=", '');

      Uint8List content = Uint8List.fromList(utf8.encode('hello world'));
      String path = '$address/${const Uuid().v4()}';
      await service.write(path, content);

      Uint8List? rsp = await service.read(path);
      expect(rsp != null, true);
      expect(utf8.decode(rsp!), utf8.decode(content));
    });

    test('Read - Versions - Success', () async {
      StorageService service =
          StorageService(privateKey, AuthService(publishingId));
      String address =
          base64UrlEncode(Digest("SHA3-256").process(privateKey.public.bytes));
      address = address.replaceAll("=", '');

      Uint8List content1 = Uint8List.fromList(utf8.encode('hello world 1'));
      Uint8List content2 = Uint8List.fromList(utf8.encode('hello world 2'));
      String path = '$address/${const Uuid().v4()}';
      await service.write(path, content1);
      await Future.delayed(const Duration(seconds: 5));
      await service.write(path, content2);

      Uint8List? rsp = await service.read(path);
      expect(rsp != null, true);
      expect(utf8.decode(rsp!), utf8.decode(content1));
    });
  });
}
