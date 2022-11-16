/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:pointycastle/api.dart';
import 'package:test/test.dart';
import 'package:tiki_sdk_dart/node/node_service.dart';
import 'package:tiki_sdk_dart/sstorage/sstorage_model_token_req.dart';
import 'package:tiki_sdk_dart/sstorage/sstorage_model_token_rsp.dart';
import 'package:tiki_sdk_dart/sstorage/sstorage_model_upload.dart';
import 'package:tiki_sdk_dart/sstorage/sstorage_repository.dart';
import 'package:tiki_sdk_dart/utils/rsa/rsa.dart';
import 'package:uuid/uuid.dart';

void main() {
  const String apiId = '';
  RsaPrivateKey privateKey = Rsa.generate().privateKey;

  group('SStorage Tests', skip: apiId.isEmpty, () {
    test('Token - Success', () async {
      SStorageRepository repository = SStorageRepository();
      String stringToSign = const Uuid().v4();
      Uint8List signature =
          Rsa.sign(privateKey, Uint8List.fromList(utf8.encode(stringToSign)));
      SStorageModelTokenReq req = SStorageModelTokenReq(
          pubKey: privateKey.public.encode(),
          signature: base64Encode(signature),
          stringToSign: stringToSign);

      SStorageModelTokenRsp rsp = await repository.token(apiId, req);
      String address =
          base64UrlEncode(Digest("SHA3-256").process(privateKey.public.bytes));
      address = address.replaceAll("=", '');

      expect(rsp.urnPrefix?.contains(address), true);
      expect(rsp.token != null, true);
      expect(rsp.expires?.isAfter(DateTime.now()), true);
      expect(rsp.type, 'Bearer');
    });

    test('Token - Bad API Id - Failure', () async {
      SStorageRepository repository = SStorageRepository();
      String stringToSign = const Uuid().v4();
      Uint8List signature =
          Rsa.sign(privateKey, Uint8List.fromList(utf8.encode(stringToSign)));
      SStorageModelTokenReq req = SStorageModelTokenReq(
          pubKey: privateKey.public.encode(),
          signature: base64Encode(signature),
          stringToSign: stringToSign);
      expect(() async => await repository.token('fail', req),
          throwsA(isA<HttpException>()));
    });

    test('Upload - Success', () async {
      SStorageRepository repository = SStorageRepository();
      String stringToSign = const Uuid().v4();
      Uint8List signature =
          Rsa.sign(privateKey, Uint8List.fromList(utf8.encode(stringToSign)));
      SStorageModelTokenReq req = SStorageModelTokenReq(
          pubKey: privateKey.public.encode(),
          signature: base64Encode(signature),
          stringToSign: stringToSign);

      SStorageModelTokenRsp rsp = await repository.token(apiId, req);
      Uint8List content = Uint8List.fromList(utf8.encode('hello world'));

      await repository.upload(
          rsp.token,
          SStorageModelUpload(
              key: '${rsp.urnPrefix}${const Uuid().v4()}', content: content));
    });

    test('Write - Success', () async {
      SStorageService service = SStorageService(apiId, privateKey);
      String address =
          base64UrlEncode(Digest("SHA3-256").process(privateKey.public.bytes));
      address = address.replaceAll("=", '');

      Uint8List content = Uint8List.fromList(utf8.encode('hello world'));
      await service.write('$address/${const Uuid().v4()}', content);
    });

    test('Read - Success', () async {
      SStorageService service = SStorageService(apiId, privateKey);
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
      SStorageService service = SStorageService(apiId, privateKey);
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
