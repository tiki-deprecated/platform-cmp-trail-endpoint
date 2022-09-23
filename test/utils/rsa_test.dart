/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/api.dart';
import 'package:test/test.dart';
import 'package:tiki_sdk_dart/utils/utils.dart';

void main() {
  group('RSA Tests', () {
    test('Generate - Success', () {
      Rsa.generate();
    });

    test('Generate Async - Success', () async {
      await Rsa.generateAsync();
    });

    test('Encode - Success', () async {
      AsymmetricKeyPair<RsaPublicKey, RsaPrivateKey> keyPair = Rsa.generate();
      String publicKeyEncoded = keyPair.publicKey.encode();
      String privateKeyEncoded = keyPair.privateKey.encode();
      expect(publicKeyEncoded.isNotEmpty, true);
      expect(privateKeyEncoded.isNotEmpty, true);
    });

    test('PublicKey Decode - Success', () async {
      AsymmetricKeyPair<RsaPublicKey, RsaPrivateKey> keyPair = Rsa.generate();
      String publicKeyEncoded = keyPair.publicKey.encode();
      RsaPublicKey publicKeyDecoded = RsaPublicKey.decode(publicKeyEncoded);
      expect(publicKeyDecoded.exponent, keyPair.publicKey.exponent);
      expect(publicKeyDecoded.modulus, keyPair.publicKey.modulus);
    });

    test('PrivateKey Decode - Success', () async {
      AsymmetricKeyPair<RsaPublicKey, RsaPrivateKey> keyPair = Rsa.generate();
      String privateKeyEncoded = keyPair.privateKey.encode();
      RsaPrivateKey privateKeyDecoded = RsaPrivateKey.decode(privateKeyEncoded);

      expect(privateKeyDecoded.modulus, keyPair.privateKey.modulus);
      expect(privateKeyDecoded.exponent, keyPair.privateKey.exponent);
      expect(privateKeyDecoded.privateExponent,
          keyPair.privateKey.privateExponent);
      expect(
          privateKeyDecoded.publicExponent, keyPair.privateKey.publicExponent);
      expect(privateKeyDecoded.p, keyPair.privateKey.p);
      expect(privateKeyDecoded.q, keyPair.privateKey.q);
    });

    test('Encrypt - Success', () async {
      AsymmetricKeyPair<RsaPublicKey, RsaPrivateKey> keyPair = Rsa.generate();
      Uint8List cipherText = Rsa.encrypt(
          keyPair.publicKey, Uint8List.fromList(utf8.encode("hello world")));
      String cipherTextString = String.fromCharCodes(cipherText);

      expect(cipherText.isNotEmpty, true);
      expect(cipherTextString.isNotEmpty, true);
    });

    test('Encrypt Async - Success', () async {
      AsymmetricKeyPair<RsaPublicKey, RsaPrivateKey> keyPair = Rsa.generate();
      Uint8List cipherText = await Rsa.encryptAsync(
          keyPair.publicKey, Uint8List.fromList(utf8.encode("hello world")));
      String cipherTextString = String.fromCharCodes(cipherText);

      expect(cipherText.isNotEmpty, true);
      expect(cipherTextString.isNotEmpty, true);
    });

    test('Encrypt Bulk - Success', () async {
      AsymmetricKeyPair<RsaPublicKey, RsaPrivateKey> keyPair = Rsa.generate();
      Map<String, Uint8List> req = {
        '1': Uint8List.fromList(utf8.encode('hello')),
        '2': Uint8List.fromList(utf8.encode('world'))
      };
      Map<String, Uint8List> rsp =
          await Rsa.encryptBulk(keyPair.publicKey, req);

      expect(utf8.decode(Rsa.decrypt(keyPair.privateKey, rsp['1']!)), 'hello');
      expect(utf8.decode(Rsa.decrypt(keyPair.privateKey, rsp['2']!)), 'world');
    });

    test('Decrypt Success', () async {
      AsymmetricKeyPair<RsaPublicKey, RsaPrivateKey> keyPair = Rsa.generate();
      String plainText = "hello world";
      Uint8List cipherText = Rsa.encrypt(
          keyPair.publicKey, Uint8List.fromList(utf8.encode(plainText)));
      String result = utf8.decode(Rsa.decrypt(keyPair.privateKey, cipherText));
      expect(result, plainText);
    });

    test('Decrypt Async - Success', () async {
      AsymmetricKeyPair<RsaPublicKey, RsaPrivateKey> keyPair = Rsa.generate();
      String plainText = "hello world";
      Uint8List cipherText = Rsa.encrypt(
          keyPair.publicKey, Uint8List.fromList(utf8.encode(plainText)));
      String result =
          utf8.decode(await Rsa.decryptAsync(keyPair.privateKey, cipherText));
      expect(result, plainText);
    });

    test('Sign - Success', () async {
      AsymmetricKeyPair<RsaPublicKey, RsaPrivateKey> keyPair = Rsa.generate();
      String message = "hello world";
      Uint8List signature = Rsa.sign(
          keyPair.privateKey, Uint8List.fromList(utf8.encode(message)));
      expect(signature.isNotEmpty, true);
    });

    test('Sign Async - Success', () async {
      AsymmetricKeyPair<RsaPublicKey, RsaPrivateKey> keyPair = Rsa.generate();
      String message = "hello world";
      Uint8List signature = await Rsa.signAsync(
          keyPair.privateKey, Uint8List.fromList(utf8.encode(message)));
      expect(signature.isNotEmpty, true);
    });

    test('Sign Bulk - 2 - Success', () async {
      AsymmetricKeyPair<RsaPublicKey, RsaPrivateKey> keyPair = Rsa.generate();
      Map<String, Uint8List> req = {
        '1': Uint8List.fromList(utf8.encode('hello')),
        '2': Uint8List.fromList(utf8.encode('world'))
      };
      Map<String, Uint8List> rsp = await Rsa.signBulk(keyPair.privateKey, req);
      expect(rsp.length, 2);
    });

    test('Verify - Success', () async {
      AsymmetricKeyPair<RsaPublicKey, RsaPrivateKey> keyPair = Rsa.generate();
      String message = "hello world";
      Uint8List signature = Rsa.sign(
          keyPair.privateKey, Uint8List.fromList(utf8.encode(message)));
      bool verify = Rsa.verify(keyPair.publicKey,
          Uint8List.fromList(utf8.encode(message)), signature);
      expect(verify, true);
    });

    test('Verify Async - Success', () async {
      AsymmetricKeyPair<RsaPublicKey, RsaPrivateKey> keyPair = Rsa.generate();
      String message = "hello world";
      Uint8List signature = Rsa.sign(
          keyPair.privateKey, Uint8List.fromList(utf8.encode(message)));
      bool verify = await Rsa.verifyAsync(keyPair.publicKey,
          Uint8List.fromList(utf8.encode(message)), signature);
      expect(verify, true);
    });

    test('Verify All - 2 - Success', () async {
      AsymmetricKeyPair<RsaPublicKey, RsaPrivateKey> keyPair = Rsa.generate();
      Map<String, Uint8List> signReq = {
        '1': Uint8List.fromList(utf8.encode('hello')),
        '2': Uint8List.fromList(utf8.encode('world'))
      };
      Map<String, Uint8List> signRsp =
          await Rsa.signBulk(keyPair.privateKey, signReq);
      Map<Uint8List, Uint8List> verifyReq = {
        signReq['1']!: signRsp['1']!,
        signReq['2']!: signRsp['2']!
      };
      bool pass = await Rsa.verifyAll(keyPair.publicKey, verifyReq);
      expect(pass, true);
    });
  });
}
