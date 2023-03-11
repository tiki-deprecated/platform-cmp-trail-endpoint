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
import 'package:tiki_sdk_dart/l0/registry/registry_service.dart';
import 'package:tiki_sdk_dart/node/backup/backup_client.dart';
import 'package:tiki_sdk_dart/node/backup/backup_service.dart';
import 'package:tiki_sdk_dart/node/block/block_service.dart';
import 'package:tiki_sdk_dart/node/key/key_model.dart';
import 'package:tiki_sdk_dart/node/key/key_service.dart';
import 'package:tiki_sdk_dart/node/node_service.dart';
import 'package:tiki_sdk_dart/node/transaction/transaction_service.dart';
import 'package:tiki_sdk_dart/tiki_sdk.dart';
import 'package:uuid/uuid.dart';

class InMemKeyStorage extends KeyStorage {
  Map<String, String> storage = {};

  @override
  Future<String?> read(String key) async => storage[key];

  @override
  Future<void> write(String key, String value) async => storage[key] = value;
}

class InMemL0Storage implements BackupClient {
  Map<String, Map<String, Uint8List>> storage = {};

  @override
  Future<void> write(String key, Uint8List value) async {
    List<String> keys = key.split('/');
    String address = keys[0];
    String id = keys[1];
    if (storage[address] == null) storage[address] = {};
    storage[address]![id] = value;
  }

  Future<Uint8List?> read(String key) async {
    List<String> keys = key.split('/');
    String address = keys[0];
    String id = keys[1];
    return storage[address]?[id];
  }
}

class InMemAuthService implements AuthService {
  @override
  // TODO: implement token
  Future<String?> get token => throw UnimplementedError();
}

class InMemBuilders {
  static const Duration _blockInterval = Duration(seconds: 1);
  static const int _maxTransactions = 200;

  static Future<NodeService> nodeService(
      {String? address, KeyStorage? keyStorage}) async {
    InMemL0Storage backupClient = InMemL0Storage();
    keyStorage = InMemKeyStorage();
    CommonDatabase database = sqlite3.openInMemory();

    KeyService keyService = KeyService(keyStorage);
    KeyModel primaryKey = address != null
        ? await keyService.get(address) ?? await keyService.create()
        : await keyService.create();

    NodeService nodeService = NodeService()
      ..blockInterval = _blockInterval
      ..maxTransactions = _maxTransactions
      ..transactionService = TransactionService(database)
      ..blockService = BlockService(database)
      ..primaryKey = primaryKey;
    nodeService.backupService =
        BackupService(backupClient, database, primaryKey, nodeService.getBlock);
    await nodeService.init();
    return nodeService;
  }

  static Future<TikiSdk> tikiSdk(
      {String? id, String origin = 'com.mytiki.tiki_sdk_dart.test'}) async {
    InMemKeyStorage keyStorage = InMemKeyStorage();

    String address = await TikiSdk.withId(id ?? const Uuid().v4(), keyStorage);
    NodeService nodeService = await InMemBuilders.nodeService(
        address: address, keyStorage: keyStorage);

    TitleService titleService =
        TitleService(origin, nodeService, nodeService.database);
    LicenseService licenseService =
        LicenseService(nodeService.database, nodeService);

    KeyService keyService = KeyService(keyStorage);
    KeyModel? primaryKey = await keyService.get(address);
    RegistryService registryService =
        RegistryService(primaryKey!.privateKey, InMemAuthService());

    return TikiSdk(titleService, licenseService, nodeService, registryService);
  }
}
