/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:pointycastle/api.dart';
import 'package:test/test.dart';
import 'package:tiki_sdk_dart/l0/storage/storage_model_token_req.dart';
import 'package:tiki_sdk_dart/l0/storage/storage_model_token_rsp.dart';
import 'package:tiki_sdk_dart/l0/storage/storage_model_upload.dart';
import 'package:tiki_sdk_dart/l0/storage/storage_repository.dart';
import 'package:tiki_sdk_dart/utils/rsa/rsa.dart';
import 'package:uuid/uuid.dart';

void main() {
  const String publishingId = '2b8de004-cbe0-4bd5-bda6-b266d54f5c90';
  RsaPrivateKey privateKey = Rsa.generate().privateKey;

  group('Storage Repository Tests', skip: publishingId.isEmpty, () {
    test('Token - Success', () async {
      StorageRepository repository = StorageRepository();
      String stringToSign = const Uuid().v4();
      Uint8List signature =
          Rsa.sign(privateKey, Uint8List.fromList(utf8.encode(stringToSign)));
      StorageModelTokenReq req = StorageModelTokenReq(
          pubKey: privateKey.public.encode(),
          signature: base64Encode(signature),
          stringToSign: stringToSign);

      StorageModelTokenRsp rsp = await repository.token(publishingId, req);
      String address =
          base64UrlEncode(Digest("SHA3-256").process(privateKey.public.bytes));
      address = address.replaceAll("=", '');

      expect(rsp.urnPrefix?.contains(address), true);
      expect(rsp.token != null, true);
      expect(rsp.expires?.isAfter(DateTime.now()), true);
      expect(rsp.type, 'Bearer');
    });

    test('Token - Bad API Id - Failure', () async {
      StorageRepository repository = StorageRepository();
      String stringToSign = const Uuid().v4();
      Uint8List signature =
          Rsa.sign(privateKey, Uint8List.fromList(utf8.encode(stringToSign)));
      StorageModelTokenReq req = StorageModelTokenReq(
          pubKey: privateKey.public.encode(),
          signature: base64Encode(signature),
          stringToSign: stringToSign);
      expect(() async => await repository.token('fail', req),
          throwsA(isA<HttpException>()));
    });

    test('Upload - Success', () async {
      StorageRepository repository = StorageRepository();
      String stringToSign = const Uuid().v4();
      Uint8List signature =
          Rsa.sign(privateKey, Uint8List.fromList(utf8.encode(stringToSign)));
      StorageModelTokenReq req = StorageModelTokenReq(
          pubKey: privateKey.public.encode(),
          signature: base64Encode(signature),
          stringToSign: stringToSign);

      StorageModelTokenRsp rsp = await repository.token(publishingId, req);
      Uint8List content = Uint8List.fromList(utf8.encode('hello world'));

      await repository.upload(
          rsp.token,
          StorageModelUpload(
              key: '${rsp.urnPrefix}${const Uuid().v4()}', content: content));
    });
  });
}
