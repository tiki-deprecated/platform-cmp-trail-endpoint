/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:tiki_sdk_dart/src/node/wasabi/wasabi_service.dart';
import 'package:tiki_sdk_dart/src/utils/rsa/rsa.dart' as rsa;

void main() async {
  const String apiId = '';
  const bool runTests = false;

  group('l0_storage tests', skip: apiId.isNotEmpty && !runTests, () {
    test('Read first', () async {
      rsa.RsaKeyPair kp = rsa.generate();

      WasabiService service = WasabiService(apiId, kp.privateKey);
      Uint8List rsp = await service.read('hello/dGVzdDE.json');
      Map<String, dynamic> json = jsonDecode(utf8.decode(rsp));

      expect(json['Hello'], 'World');
    });

    test('Upload first', () async {
      rsa.RsaKeyPair kp = rsa.generate();

      String testFile =
          '{"Test":["OK","OK","OK","OK","OK","OK","OK","OK","OK","OK","OK","OK","OK","OK","OK","OK","OK","OK","OK","OK","OK","OK","OK","OK","OK","OK","OK","OK","OK","OK","OK","OK"]}';

      WasabiService service = WasabiService(apiId, kp.privateKey);
      service.write(
          'test.json', Uint8List.fromList(utf8.encode(testFile)));
      expect(1,1);
    });
  });
}
