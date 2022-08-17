/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/api.dart';
import 'package:test/test.dart';
import 'package:tiki_sdk_dart/src/utils/ec/ec.dart' as ec;
import 'package:tiki_sdk_dart/src/utils/ec/ec_private_key.dart';
import 'package:tiki_sdk_dart/src/utils/ec/ec_public_key.dart';

void main() {
  group('crypto-ec unit tests', () {
    test('generate_success', () {
      ec.generate();
    });

    test('generateAsync_success', () async {
      await ec.generateAsync();
    });

    test('encode_success', () async {
      AsymmetricKeyPair<CryptoECPublicKey, CryptoECPrivateKey> keyPair =
          ec.generate();
      String publicKeyEncoded = keyPair.publicKey.encode();
      String privateKeyEncoded = keyPair.privateKey.encode();
      expect(publicKeyEncoded.isNotEmpty, true);
      expect(privateKeyEncoded.isNotEmpty, true);
    });

    test('publicKeyDecode_success', () async {
      AsymmetricKeyPair<CryptoECPublicKey, CryptoECPrivateKey> keyPair =
          ec.generate();
      String publicKeyEncoded = keyPair.publicKey.encode();
      CryptoECPublicKey publicKeyDecoded =
          CryptoECPublicKey.decode(publicKeyEncoded);
      expect(publicKeyDecoded.Q, keyPair.publicKey.Q);
      expect(publicKeyDecoded.Q?.x, keyPair.publicKey.Q?.x);
      expect(publicKeyDecoded.Q?.y, keyPair.publicKey.Q?.y);
      expect(publicKeyDecoded.Q?.curve, keyPair.publicKey.Q?.curve);
    });

    test('privateKeyDecode_success', () async {
      AsymmetricKeyPair<CryptoECPublicKey, CryptoECPrivateKey> keyPair =
          ec.generate();
      String privateKeyEncoded = keyPair.privateKey.encode();
      CryptoECPrivateKey privateKeyDecoded =
          CryptoECPrivateKey.decode(privateKeyEncoded);

      expect(privateKeyDecoded.d, keyPair.privateKey.d);
      expect(privateKeyDecoded.parameters?.curve,
          keyPair.privateKey.parameters?.curve);
    });

    test('sign_success', () async {
      AsymmetricKeyPair<CryptoECPublicKey, CryptoECPrivateKey> keyPair =
          ec.generate();
      String message = "hello world";
      Uint8List signature =
          ec.sign(keyPair.privateKey, Uint8List.fromList(utf8.encode(message)));
      expect(signature.isNotEmpty, true);
    });

    test('signAsync_success', () async {
      AsymmetricKeyPair<CryptoECPublicKey, CryptoECPrivateKey> keyPair =
          ec.generate();
      String message = "hello world";
      Uint8List signature = await ec.signAsync(
          keyPair.privateKey, Uint8List.fromList(utf8.encode(message)));
      expect(signature.isNotEmpty, true);
    });

    test('signBulk_success', () async {
      AsymmetricKeyPair<CryptoECPublicKey, CryptoECPrivateKey> keyPair =
          ec.generate();
      Map<String, Uint8List> req = {
        '1': Uint8List.fromList(utf8.encode('hello')),
        '2': Uint8List.fromList(utf8.encode('world'))
      };
      Map<String, Uint8List> rsp = await ec.signBulk(keyPair.privateKey, req);
      expect(rsp.length, 2);
    });

    test('verify_success', () async {
      AsymmetricKeyPair<CryptoECPublicKey, CryptoECPrivateKey> keyPair =
          ec.generate();
      String message = "hello world";
      Uint8List signature =
          ec.sign(keyPair.privateKey, Uint8List.fromList(utf8.encode(message)));
      bool verify = ec.verify(keyPair.publicKey,
          Uint8List.fromList(utf8.encode(message)), signature);
      expect(verify, true);
    });

    test('verifyAsync_success', () async {
      AsymmetricKeyPair<CryptoECPublicKey, CryptoECPrivateKey> keyPair =
          ec.generate();
      String message = "hello world";
      Uint8List signature =
          ec.sign(keyPair.privateKey, Uint8List.fromList(utf8.encode(message)));
      bool verify = await ec.verifyAsync(keyPair.publicKey,
          Uint8List.fromList(utf8.encode(message)), signature);
      expect(verify, true);
    });

    test('verifyAll_success', () async {
      AsymmetricKeyPair<CryptoECPublicKey, CryptoECPrivateKey> keyPair =
          ec.generate();
      Map<String, Uint8List> signReq = {
        '1': Uint8List.fromList(utf8.encode('hello')),
        '2': Uint8List.fromList(utf8.encode('world'))
      };
      Map<String, Uint8List> signRsp =
          await ec.signBulk(keyPair.privateKey, signReq);
      Map<Uint8List, Uint8List> verifyReq = {
        signReq['1']!: signRsp['1']!,
        signReq['2']!: signRsp['2']!
      };
      bool pass = await ec.verifyAll(keyPair.publicKey, verifyReq);
      expect(pass, true);
    });
  });
}
