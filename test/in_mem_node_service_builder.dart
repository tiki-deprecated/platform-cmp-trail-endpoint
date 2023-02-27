/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:sqlite3/common.dart';
import 'package:tiki_sdk_dart/node/backup/backup_service.dart';
import 'package:tiki_sdk_dart/node/block/block_service.dart';
import 'package:tiki_sdk_dart/node/key/key_service.dart';
import 'package:tiki_sdk_dart/node/node_service.dart';
import 'package:tiki_sdk_dart/node/transaction/transaction_service.dart';

import 'in_mem_key.dart';
import 'in_mem_l0_storage.dart';

class InMemNodeServiceBuilder {
  late final InMemL0Storage backupClient;
  late final InMemKeyStorage keyStorage;
  late final CommonDatabase database;

  Duration _blockInterval = const Duration(minutes: 1);
  int _maxTransactions = 200;
  String? _address;

  set blockInterval(Duration duration) => _blockInterval = duration;
  set maxTransactions(int maxTransactions) =>
      _maxTransactions = maxTransactions;
  set address(String? address) => _address = address;

  Future<NodeService> build() async {
    backupClient = InMemL0Storage();
    keyStorage = InMemKeyStorage();
    database = sqlite3.openInMemory();
    KeyModel primaryKey = await _loadPrimaryKey();
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

  Future<KeyModel> _loadPrimaryKey() async {
    KeyService keyService = KeyService(keyStorage);
    if (_address != null) {
      KeyModel? key = await keyService.get(_address!);
      if (key != null) {
        return key;
      }
    }
    return await keyService.create();
  }
}
