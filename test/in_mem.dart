/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:typed_data';

import 'package:sqlite3/common.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:tiki_sdk_dart/cache/license/license_service.dart';
import 'package:tiki_sdk_dart/cache/title/title_service.dart';
import 'package:tiki_sdk_dart/l0/auth/auth_service.dart';
import 'package:tiki_sdk_dart/l0/registry/registry_model_rsp.dart';
import 'package:tiki_sdk_dart/l0/registry/registry_service.dart';
import 'package:tiki_sdk_dart/node/backup/backup_client.dart';
import 'package:tiki_sdk_dart/node/backup/backup_service.dart';
import 'package:tiki_sdk_dart/node/block/block_service.dart';
import 'package:tiki_sdk_dart/node/key/key_model.dart';
import 'package:tiki_sdk_dart/node/key/key_service.dart';
import 'package:tiki_sdk_dart/node/node_service.dart';
import 'package:tiki_sdk_dart/node/transaction/transaction_service.dart';
import 'package:tiki_sdk_dart/node/xchain/xchain_client.dart';
import 'package:tiki_sdk_dart/node/xchain/xchain_service.dart';
import 'package:tiki_sdk_dart/tiki_sdk.dart';
import 'package:tiki_sdk_dart/utils/rsa/rsa.dart';
import 'package:tiki_sdk_dart/utils/rsa/rsa_private_key.dart';
import 'package:uuid/uuid.dart';

class InMemKeyStorage extends KeyStorage {
  Map<String, String> storage = {};

  @override
  Future<String> generate() async {
    RsaKeyPair rsaKeyPair = await Rsa.generateAsync();
    return rsaKeyPair.privateKey.encode();
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

class InMemAuthService implements AuthService {
  @override
  Future<String?> get token => Future.value('dummy');
}

class InMemRegistryService implements RegistryService {
  final RsaPrivateKey privateKey = Rsa.generate().privateKey;
  final Set<String> addresses = {};

  InMemRegistryService({String? address}) {
    if (address != null) addresses.add(address);
  }

  @override
  Future<RegistryModelRsp> get(String id, {String? customerAuth}) {
    return Future.value(
        RegistryModelRsp(signKey: privateKey, addresses: addresses.toList()));
  }

  @override
  Future<RegistryModelRsp> register(String id, String address,
      {String? customerAuth}) {
    addresses.add(address);
    return Future.value(
        RegistryModelRsp(signKey: privateKey, addresses: addresses.toList()));
  }
}

class InMemBuilders {
  static const Duration _blockInterval = Duration(seconds: 1);
  static const int _maxTransactions = 200;

  static Future<NodeService> nodeService(
      {String? id, KeyStorage? keyStorage}) async {
    InMemL0Storage backupClient = InMemL0Storage();
    keyStorage ??= InMemKeyStorage();
    CommonDatabase database = sqlite3.openInMemory();

    KeyService keyService = KeyService(keyStorage);
    KeyModel primaryKey = id != null
        ? await keyService.get(id) ?? await keyService.create()
        : await keyService.create();

    NodeService nodeService = NodeService()
      ..blockInterval = _blockInterval
      ..maxTransactions = _maxTransactions
      ..transactionService = TransactionService(database)
      ..blockService = BlockService(database)
      ..primaryKey = primaryKey
      ..xChainService = XChainService(backupClient, database);
    nodeService.backupService =
        BackupService(backupClient, database, primaryKey, nodeService.getBlock);
    await nodeService.init();
    return nodeService;
  }

  static Future<TikiSdk> tikiSdk(
      {String? id, String origin = 'com.mytiki.tiki_sdk_dart.test'}) async {
    id ??= const Uuid().v4();
    InMemKeyStorage keyStorage = InMemKeyStorage();

    String address = await TikiSdk.withId(id, keyStorage);
    NodeService nodeService =
        await InMemBuilders.nodeService(id: id, keyStorage: keyStorage);

    TitleService titleService =
        TitleService(origin, nodeService, nodeService.database);
    LicenseService licenseService =
        LicenseService(nodeService.database, nodeService);
    return TikiSdk(titleService, licenseService, nodeService,
        InMemRegistryService(address: address));
  }
}
