/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/api.dart';
import 'package:pointycastle/ecc/api.dart';
import 'package:pointycastle/ecc/curves/secp256r1.dart';
import 'package:pointycastle/key_generators/api.dart';
import 'package:pointycastle/key_generators/ec_key_generator.dart';

import '../crypto_utils.dart' as utils;
import '../isolate/isolate.dart';
import 'crypto_ec_private_key.dart';
import 'crypto_ec_public_key.dart';

Future<AsymmetricKeyPair<CryptoECPublicKey, CryptoECPrivateKey>>
    generateAsync() =>
        compute((_) => generate(), "").then((keyPair) => keyPair);

AsymmetricKeyPair<CryptoECPublicKey, CryptoECPrivateKey> generate() {
  final ECKeyGeneratorParameters keyGeneratorParameters =
      ECKeyGeneratorParameters(ECCurve_secp256r1());

  ECKeyGenerator ecKeyGenerator = ECKeyGenerator();
  ecKeyGenerator
      .init(ParametersWithRandom(keyGeneratorParameters, utils.secureRandom()));
  AsymmetricKeyPair<PublicKey, PrivateKey> keyPair =
      ecKeyGenerator.generateKeyPair();
  ECPublicKey publicKey = keyPair.publicKey as ECPublicKey;
  ECPrivateKey privateKey = keyPair.privateKey as ECPrivateKey;

  return AsymmetricKeyPair<CryptoECPublicKey, CryptoECPrivateKey>(
      CryptoECPublicKey(publicKey.Q, publicKey.parameters),
      CryptoECPrivateKey(privateKey.d, privateKey.parameters));
}

Uint8List sign(CryptoECPrivateKey key, Uint8List message) {
  Signer signer = Signer("SHA-256/ECDSA");
  signer.init(
      true,
      ParametersWithRandom(
          PrivateKeyParameter<ECPrivateKey>(key), utils.secureRandom()));
  ECSignature signature = signer.generateSignature(message) as ECSignature;

  BytesBuilder bytesBuilder = BytesBuilder();
  Uint8List encodedR = utils.encodeBigInt(signature.r);
  bytesBuilder.addByte(encodedR.length);
  bytesBuilder.add(encodedR);
  bytesBuilder.add(utils.encodeBigInt(signature.s));
  return bytesBuilder.toBytes();
}

Future<Uint8List> signAsync(CryptoECPrivateKey key, Uint8List message) {
  Map<String, String> q = {};
  q['message'] = base64.encode(message);
  q['key'] = key.encode();
  return compute(
          (Map<String, String> q) => sign(CryptoECPrivateKey.decode(q['key']!),
              base64.decode(q['message']!)),
          q)
      .then((signature) => signature);
}

Future<Map<String, Uint8List>> signBulk(
    CryptoECPrivateKey key, Map<String, Uint8List> req) {
  Map<String, String> q =
      req.map((key, value) => MapEntry(key, base64.encode(value)));
  q['CRYPTOECPRIVATEKEY'] = key.encode();
  return compute((Map<String, String> q) {
    CryptoECPrivateKey ec =
        CryptoECPrivateKey.decode(q.remove('CRYPTOECPRIVATEKEY')!);
    return q.map((key, value) => MapEntry(key, sign(ec, base64.decode(value))));
  }, q)
      .then((rsp) => rsp);
}

bool verify(CryptoECPublicKey key, Uint8List message, Uint8List signature) {
  Signer signer = Signer("SHA-256/ECDSA");
  signer.init(false, PublicKeyParameter<ECPublicKey>(key));

  int rLength = signature[0];
  Uint8List encodedR = signature.sublist(1, 1 + rLength);
  Uint8List encodedS = signature.sublist(1 + rLength);
  ECSignature ecSignature =
      ECSignature(utils.decodeBigInt(encodedR), utils.decodeBigInt(encodedS));

  return signer.verifySignature(message, ecSignature);
}

Future<bool> verifyAsync(
    CryptoECPublicKey key, Uint8List message, Uint8List signature) {
  Map<String, String> q = {};
  q['message'] = base64.encode(message);
  q['signature'] = base64.encode(signature);
  q['key'] = key.encode();
  return compute(
          (Map<String, String> q) => verify(CryptoECPublicKey.decode(q['key']!),
              base64.decode(q['message']!), base64.decode(q['signature']!)),
          q)
      .then((isVerified) => isVerified);
}

Future<bool> verifyAll(CryptoECPublicKey key, Map<Uint8List, Uint8List> req) {
  Map<String, String> q = req
      .map((key, value) => MapEntry(base64.encode(key), base64.encode(value)));
  q['CRYPTOECPUBLICKEY'] = key.encode();
  return compute((Map<String, String> q) {
    CryptoECPublicKey ec =
        CryptoECPublicKey.decode(q.remove('CRYPTOECPUBLICKEY')!);
    for (MapEntry<String, String> entry in q.entries) {
      if (!verify(ec, base64.decode(entry.key), base64.decode(entry.value))) {
        return false;
      }
    }
    return true;
  }, q)
      .then((isVerified) => isVerified);
}
