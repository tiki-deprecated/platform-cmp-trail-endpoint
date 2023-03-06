/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';

import '../isolate.dart';
import 'rsa_private_key.dart';
import 'rsa_public_key.dart';

/// A RSA asymmetric key pair
typedef RsaKeyPair = AsymmetricKeyPair<RsaPublicKey, RsaPrivateKey>;

/// Utility functions for asymmetric keys in RSA
class Rsa {
  /// Generates a [RsaKeyPair] a [secureRandom]
  static RsaKeyPair generate() {
    final keyGen = RSAKeyGenerator()
      ..init(ParametersWithRandom(
          RSAKeyGeneratorParameters(BigInt.parse('65537'), 2048, 64),
          secureRandom()));

    AsymmetricKeyPair<PublicKey, PrivateKey> keyPair = keyGen.generateKeyPair();
    RSAPublicKey publicKey = keyPair.publicKey as RSAPublicKey;
    RSAPrivateKey privateKey = keyPair.privateKey as RSAPrivateKey;

    return RsaKeyPair(
        RsaPublicKey(publicKey.modulus!, publicKey.publicExponent!),
        RsaPrivateKey(privateKey.modulus!, privateKey.privateExponent!,
            privateKey.p, privateKey.q));
  }

  static Future<RsaKeyPair> generateAsync() =>
      compute((_) => generate(), "").then((keyPair) => keyPair);

  static Uint8List encrypt(RsaPublicKey key, Uint8List plaintext) {
    final encryptor = OAEPEncoding(RSAEngine())
      ..init(true, PublicKeyParameter<RSAPublicKey>(key));
    return processInBlocks(encryptor, plaintext);
  }

  static Future<Map<String, Uint8List>> encryptBulk(
      RsaPublicKey key, Map<String, Uint8List> req) {
    Map<String, String> q =
        req.map((key, value) => MapEntry(key, base64.encode(value)));
    q['CRYPTORSAPUBLICKEY'] = key.encode();
    return compute((Map<String, String> q) {
      RsaPublicKey aes = RsaPublicKey.decode(q.remove('CRYPTORSAPUBLICKEY')!);
      return q.map(
          (key, value) => MapEntry(key, encrypt(aes, base64.decode(value))));
    }, q)
        .then((rsp) => rsp);
  }

  static Future<Uint8List> encryptAsync(RsaPublicKey key, Uint8List plaintext) {
    Map<String, String> q = {};
    q['plaintext'] = base64.encode(plaintext);
    q['key'] = key.encode();
    return compute(
            (Map<String, String> q) => encrypt(
                RsaPublicKey.decode(q['key']!), base64.decode(q['plaintext']!)),
            q)
        .then((ciphertext) => ciphertext);
  }

  static Uint8List decrypt(RsaPrivateKey key, Uint8List ciphertext) {
    final decryptor = OAEPEncoding(RSAEngine())
      ..init(false, PrivateKeyParameter<RSAPrivateKey>(key));
    return processInBlocks(decryptor, ciphertext);
  }

  static Future<Uint8List> decryptAsync(
      RsaPrivateKey key, Uint8List ciphertext) {
    Map<String, String> q = {};
    q['ciphertext'] = base64.encode(ciphertext);
    q['key'] = key.encode();
    return compute(
            (Map<String, String> q) => decrypt(RsaPrivateKey.decode(q['key']!),
                base64.decode(q['ciphertext']!)),
            q)
        .then((plaintext) => plaintext);
  }

  static Uint8List sign(RsaPrivateKey key, Uint8List message) {
    RSASigner signer = RSASigner(SHA256Digest(), '0609608648016503040201');
    signer.init(true, PrivateKeyParameter<RSAPrivateKey>(key));
    RSASignature signature = signer.generateSignature(message);
    return signature.bytes;
  }

  static Future<Map<String, Uint8List>> signBulk(
      RsaPrivateKey key, Map<String, Uint8List> req) {
    Map<String, String> q =
        req.map((key, value) => MapEntry(key, base64.encode(value)));
    q['CRYPTORSAPRIVATEKEY'] = key.encode();
    return compute((Map<String, String> q) {
      RsaPrivateKey aes =
          RsaPrivateKey.decode(q.remove('CRYPTORSAPRIVATEKEY')!);
      return q
          .map((key, value) => MapEntry(key, sign(aes, base64.decode(value))));
    }, q)
        .then((rsp) => rsp);
  }

  static Future<Uint8List> signAsync(RsaPrivateKey key, Uint8List message) {
    Map<String, String> q = {};
    q['message'] = base64.encode(message);
    q['key'] = key.encode();
    return compute(
            (Map<String, String> q) => sign(
                RsaPrivateKey.decode(q['key']!), base64.decode(q['message']!)),
            q)
        .then((signature) => signature);
  }

  static bool verify(RsaPublicKey key, Uint8List message, Uint8List signature) {
    RSASignature rsaSignature = RSASignature(signature);
    final verifier = RSASigner(SHA256Digest(), '0609608648016503040201');
    verifier.init(false, PublicKeyParameter<RSAPublicKey>(key));
    try {
      return verifier.verifySignature(message, rsaSignature);
    } on ArgumentError {
      return false;
    }
  }

  static Future<bool> verifyAsync(
      RsaPublicKey key, Uint8List message, Uint8List signature) {
    Map<String, String> q = {};
    q['message'] = base64.encode(message);
    q['signature'] = base64.encode(signature);
    q['key'] = key.encode();
    return compute(
            (Map<String, String> q) => verify(RsaPublicKey.decode(q['key']!),
                base64.decode(q['message']!), base64.decode(q['signature']!)),
            q)
        .then((isVerified) => isVerified);
  }

  static Future<bool> verifyAll(
      RsaPublicKey key, Map<Uint8List, Uint8List> req) {
    Map<String, String> q = req.map(
        (key, value) => MapEntry(base64.encode(key), base64.encode(value)));
    q['CRYPTORSAPUBLICKEY'] = key.encode();
    return compute((Map<String, String> q) {
      RsaPublicKey aes = RsaPublicKey.decode(q.remove('CRYPTORSAPUBLICKEY')!);
      for (MapEntry<String, String> entry in q.entries) {
        if (!verify(
            aes, base64.decode(entry.key), base64.decode(entry.value))) {
          return false;
        }
      }
      return true;
    }, q)
        .then((isVerified) => isVerified);
  }

  static FortunaRandom secureRandom() {
    var secureRandom = FortunaRandom();
    var random = Random.secure();
    final seeds = <int>[];
    for (int i = 0; i < 32; i++) {
      seeds.add(random.nextInt(255));
    }
    secureRandom.seed(KeyParameter(Uint8List.fromList(seeds)));
    return secureRandom;
  }

  static Uint8List processInBlocks(
      AsymmetricBlockCipher engine, Uint8List input) {
    final numBlocks = input.length ~/ engine.inputBlockSize +
        ((input.length % engine.inputBlockSize != 0) ? 1 : 0);

    final output = Uint8List(numBlocks * engine.outputBlockSize);

    var inputOffset = 0;
    var outputOffset = 0;
    while (inputOffset < input.length) {
      final chunkSize = (inputOffset + engine.inputBlockSize <= input.length)
          ? engine.inputBlockSize
          : input.length - inputOffset;

      outputOffset += engine.processBlock(
          input, inputOffset, chunkSize, output, outputOffset);

      inputOffset += chunkSize;
    }

    return (output.length == outputOffset)
        ? output
        : output.sublist(0, outputOffset);
  }
}
