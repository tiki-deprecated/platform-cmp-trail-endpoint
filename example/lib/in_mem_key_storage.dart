/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';
import 'package:tiki_idp/tiki_idp.dart';

class InMemKeyStorage extends KeyPlatform {
  Map<String, String> storage = {};

  @override
  Future<String> generate() async {
    FortunaRandom secureRandom = FortunaRandom();
    Random random = Random.secure();
    final seeds = <int>[];
    for (int i = 0; i < 32; i++) {
      seeds.add(random.nextInt(255));
    }
    secureRandom.seed(KeyParameter(Uint8List.fromList(seeds)));
    final keyGen = RSAKeyGenerator()
      ..init(ParametersWithRandom(
          RSAKeyGeneratorParameters(BigInt.parse('65537'), 2048, 64),
          secureRandom));

    AsymmetricKeyPair<PublicKey, PrivateKey> keyPair = keyGen.generateKeyPair();
    RSAPrivateKey pk = keyPair.privateKey as RSAPrivateKey;
    return TikiIdp.pkcs8(pk.modulus!, pk.privateExponent!, pk.p!, pk.q!);
  }

  @override
  Future<String?> read(String key) async => storage[key];

  @override
  Future<void> write(String key, String value) async => storage[key] = value;
}
