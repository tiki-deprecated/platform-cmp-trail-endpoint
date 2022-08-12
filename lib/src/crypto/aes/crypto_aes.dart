/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/block/aes.dart';
import 'package:pointycastle/block/modes/cbc.dart';
import 'package:pointycastle/key_derivators/api.dart';
import 'package:pointycastle/padded_block_cipher/padded_block_cipher_impl.dart';
import 'package:pointycastle/paddings/pkcs7.dart';

import '../crypto_utils.dart' as utils;
import 'crypto_aes_key.dart';

CryptoAESKey generate() => CryptoAESKey(utils.secureRandom().nextBytes(32));

Future<CryptoAESKey> generateAsync() =>
    compute((_) => generate(), "").then((key) => key);

Uint8List encrypt(CryptoAESKey key, Uint8List plaintext) {
  if (key.key!.length != 32) throw ArgumentError("key length must be 256-bits");

  Uint8List iv = utils.secureRandom().nextBytes(16);
  final cipher = PaddedBlockCipherImpl(
    PKCS7Padding(),
    CBCBlockCipher(AESEngine()),
  )..init(
      true,
      PaddedBlockCipherParameters<CipherParameters, CipherParameters>(
        ParametersWithIV<KeyParameter>(KeyParameter(key.key!), iv),
        null,
      ),
    );

  BytesBuilder cipherBuilder = BytesBuilder();
  cipherBuilder.add(iv);
  cipherBuilder.add(cipher.process(utils.addPadding(plaintext, 16, pad: 0)));
  return cipherBuilder.toBytes();
}

Future<Map<String, Uint8List>> encryptBulk(
    CryptoAESKey key, Map<String, Uint8List> req) {
  Map<String, String> q =
      req.map((key, value) => MapEntry(key, base64.encode(value)));
  q['CRYPTOAESKEY'] = key.encode();
  return compute((Map<String, String> q) {
    CryptoAESKey aes = CryptoAESKey.decode(q.remove('CRYPTOAESKEY')!);
    return q
        .map((key, value) => MapEntry(key, encrypt(aes, base64.decode(value))));
  }, q)
      .then((rsp) => rsp);
}

Future<Uint8List> encryptAsync(CryptoAESKey key, Uint8List plaintext) {
  Map<String, String> q = {};
  q['key'] = key.encode();
  q['plaintext'] = base64.encode(plaintext);
  return compute(
          (Map<String, String> q) => encrypt(
              CryptoAESKey.decode(q['key']!), base64.decode(q['plaintext']!)),
          q)
      .then((ciphertext) => ciphertext);
}

Uint8List decrypt(CryptoAESKey key, Uint8List ciphertext) {
  if (key.key!.length != 32) throw ArgumentError("key length must be 256-bits");
  if (ciphertext.length < 16) {
    throw ArgumentError("cipher length must be > 128-bits");
  }

  Uint8List iv = ciphertext.sublist(0, 16);
  Uint8List message = ciphertext.sublist(16);

  final cipher = PaddedBlockCipherImpl(
    PKCS7Padding(),
    CBCBlockCipher(AESEngine()),
  )..init(
      false,
      PaddedBlockCipherParameters<CipherParameters, CipherParameters>(
        ParametersWithIV<KeyParameter>(KeyParameter(key.key!), iv),
        null,
      ),
    );

  return utils.removePadding(cipher.process(message), pad: 0);
}

Future<Map<String, Uint8List>> decryptBulk(
    CryptoAESKey key, Map<String, Uint8List> req) {
  Map<String, String> q =
      req.map((key, value) => MapEntry(key, base64.encode(value)));
  q['CRYPTOAESKEY'] = key.encode();
  return compute((Map<String, String> q) {
    CryptoAESKey aes = CryptoAESKey.decode(q.remove('CRYPTOAESKEY')!);
    return q
        .map((key, value) => MapEntry(key, decrypt(aes, base64.decode(value))));
  }, q)
      .then((rsp) => rsp);
}

Future<Uint8List> decryptAsync(CryptoAESKey key, Uint8List ciphertext) {
  Map<String, String> q = {};
  q['key'] = key.encode();
  q['ciphertext'] = base64.encode(ciphertext);
  return compute(
          (Map<String, String> q) => decrypt(
              CryptoAESKey.decode(q['key']!), base64.decode(q['ciphertext']!)),
          q)
      .then((plaintext) => plaintext);
}

CryptoAESKey derive(String passphrase, {Uint8List? salt}) {
  salt ??= utils.secureRandom().nextBytes(16);
  return _derive(Uint8List.fromList(utf8.encode(passphrase)), salt);
}

Future<CryptoAESKey> deriveAsync(String passphrase, {Uint8List? salt}) {
  salt ??= utils.secureRandom().nextBytes(16);
  Map<String, String> q = {};
  q['salt'] = base64.encode(salt);
  q['passphrase'] = passphrase;
  return compute(
          (Map<String, String> q) => _derive(base64.decode(q['salt']!),
              Uint8List.fromList(utf8.encode(q['passphrase']!))),
          q)
      .then((key) => key);
}

CryptoAESKey _derive(Uint8List passphrase, Uint8List salt) {
  int iterations = 200000;
  KeyDerivator keyDerivator = KeyDerivator('SHA-1/HMAC/PBKDF2');
  Pbkdf2Parameters pbkdf2parameters = Pbkdf2Parameters(salt, iterations, 32);
  keyDerivator.init(pbkdf2parameters);
  return CryptoAESKey(keyDerivator.process(passphrase));
}
