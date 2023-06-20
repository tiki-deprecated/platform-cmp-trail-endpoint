/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';
import 'package:sqlite3/common.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:tiki_idp/tiki_idp.dart';
import 'package:tiki_trail/key.dart';
import 'package:tiki_trail/node/backup/backup_client.dart';
import 'package:tiki_trail/node/backup/backup_service.dart';
import 'package:tiki_trail/node/block/block_service.dart';
import 'package:tiki_trail/node/node_service.dart';
import 'package:tiki_trail/node/transaction/transaction_service.dart';
import 'package:tiki_trail/node/xchain/xchain_client.dart';
import 'package:tiki_trail/node/xchain/xchain_service.dart';
import 'package:tiki_trail/tiki_trail.dart';
import 'package:uuid/uuid.dart';

import 'idp.dart' as idpFixture;

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

class InMemL0Storage implements BackupClient, XChainClient {
  Map<String, Map<String, Uint8List>> storage = {};

  @override
  Future<void> write(String key, Uint8List value) async {
    List<String> keys = key.split('/');
    String address = keys[0];
    String id = keys[1];
    if (storage[address] == null) storage[address] = {};
    storage[address]![id] = value;
  }

  @override
  Future<Uint8List?> read(String key) async {
    List<String> keys = key.split('/');
    String address = keys[0];
    String id = keys[1];
    return storage[address]?[id];
  }

  @override
  Future<Set<String>> list(String key) async {
    Set<String> keys = {};
    storage.forEach((addr, value) {
      value.forEach((id, value) {
        keys.add('$addr/$id');
      });
    });
    return keys;
  }
}

class InMemBuilders {
  static const Duration _blockInterval = Duration(seconds: 1);
  static const int _maxTransactions = 200;

  static Future<NodeService> nodeService({Key? key}) async {
    key ??= await idpFixture.key;
    InMemL0Storage backupClient = InMemL0Storage();
    CommonDatabase database = sqlite3.openInMemory();
    NodeService nodeService = NodeService()
      ..blockInterval = _blockInterval
      ..maxTransactions = _maxTransactions
      ..transactionService = TransactionService(database, idpFixture.idp)
      ..blockService = BlockService(database)
      ..key = key
      ..xChainService = XChainService(backupClient, idpFixture.idp, database);
    nodeService.backupService = await BackupService(
            backupClient, idpFixture.idp, database, nodeService.getBlock, key)
        .init();
    await nodeService.init();
    return nodeService;
  }

  static Future<TikiTrail> tikiTrail(
      {String? id, String origin = 'com.mytiki.tiki_trail.test'}) async {
    id ??= const Uuid().v4();
    Key key = await TikiTrail.withId(id, idpFixture.idp);
    NodeService nodeService = await InMemBuilders.nodeService(key: key);
    return TikiTrail(origin, nodeService, idpFixture.idp);
  }
}
