/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:tiki_sdk_dart/src/wallet/crypto/aes/crypto_aes.dart' as aes;
import 'package:tiki_sdk_dart/src/wallet/crypto/aes/crypto_aes_key.dart';
import 'package:tiki_sdk_dart/src/wallet/crypto/crypto_utils.dart' as utils;

void main() {
  group('crypto-aes unit tests', () {
    test('generate_success', () {
      aes.generate();
    });

    test('generateAsync_success', () async {
      await aes.generateAsync();
    });

    test('encode_success', () async {
      CryptoAESKey key = aes.generate();
      String keyEncoded = key.encode();
      expect(keyEncoded.isNotEmpty, true);
    });

    test('keyDecode_success', () async {
      CryptoAESKey key = aes.generate();
      String keyEncoded = key.encode();
      CryptoAESKey keyDecoded = CryptoAESKey.decode(keyEncoded);
      expect(keyDecoded.key, key.key);
    });

    test('encrypt_success', () async {
      CryptoAESKey key = aes.generate();
      String plaintext = "hello";
      Uint8List cipherText =
          aes.encrypt(key, Uint8List.fromList(utf8.encode(plaintext)));
      expect(cipherText.isNotEmpty, true);
    });

    test('encryptAsync_success', () async {
      CryptoAESKey key = aes.generate();
      String plaintext = "hello";
      Uint8List cipherText = await aes.encryptAsync(
          key, Uint8List.fromList(utf8.encode(plaintext)));
      expect(cipherText.isNotEmpty, true);
    });

    test('encryptBulk_success', () async {
      CryptoAESKey key = aes.generate();
      Map<String, Uint8List> req = {
        '1': Uint8List.fromList(utf8.encode('hello')),
        '2': Uint8List.fromList(utf8.encode('world'))
      };
      Map<String, Uint8List> rsp = await aes.encryptBulk(key, req);

      expect(utf8.decode(aes.decrypt(key, rsp['1']!)), 'hello');
      expect(utf8.decode(aes.decrypt(key, rsp['2']!)), 'world');
    });

    test('decrypt_success', () async {
      CryptoAESKey key = aes.generate();
      String plaintext = "hello";
      Uint8List cipherText =
          aes.encrypt(key, Uint8List.fromList(utf8.encode(plaintext)));
      String result = utf8.decode(aes.decrypt(key, cipherText));
      expect(result, plaintext);
    });

    test('decryptAsync_success', () async {
      CryptoAESKey key = aes.generate();
      String plaintext = "hello";
      Uint8List cipherText =
          aes.encrypt(key, Uint8List.fromList(utf8.encode(plaintext)));
      String result = utf8.decode(await aes.decryptAsync(key, cipherText));
      expect(result, plaintext);
    });

    test('derive_success', () async {
      Uint8List salt = utils.secureRandom().nextBytes(16);
      String passphrase = 'passphrase';
      CryptoAESKey key1 = aes.derive(passphrase, salt: salt);
      CryptoAESKey key2 = aes.derive(passphrase, salt: salt);

      expect(key1.key, key2.key);

      String plaintext = "hello";
      Uint8List cipherText =
          aes.encrypt(key1, Uint8List.fromList(utf8.encode(plaintext)));
      String result = utf8.decode(aes.decrypt(key1, cipherText));
      expect(result, plaintext);
    });

    test('deriveAsync_success', () async {
      Uint8List salt = utils.secureRandom().nextBytes(16);
      String passphrase = 'passphrase';
      CryptoAESKey key1 = await aes.deriveAsync(passphrase, salt: salt);
      CryptoAESKey key2 = await aes.deriveAsync(passphrase, salt: salt);

      expect(key1.key, key2.key);

      String plaintext = "hello";
      Uint8List cipherText =
          aes.encrypt(key1, Uint8List.fromList(utf8.encode(plaintext)));
      String result = utf8.decode(aes.decrypt(key1, cipherText));
      expect(result, plaintext);
    });
  });
}
