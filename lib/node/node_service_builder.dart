/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:async';
import 'dart:convert';

import 'package:sqlite3/sqlite3.dart';

import 'l0_storage.dart';
import 'node_service.dart';
import 'xchain/xchain_service.dart';

export './backup/backup_service.dart';
export './block/block_service.dart';
export './key/key_service.dart';
export './transaction/transaction_service.dart';

/// The Builder for the blockchain Node.
class NodeServiceBuilder {
  KeyStorage? _keyStorage;
  String? _apiKey;
  List<String> _readOnly = [];
  Duration _blockInterval = const Duration(minutes: 1);
  int _maxTransactions = 200;
  String? _databaseDir;
  String? _address;

  set apiKey(String? apiKey) => _apiKey = apiKey;
  set readOnly(List<String> addresses) => _readOnly = addresses;
  set keyStorage(KeyStorage keyStorage) => _keyStorage = keyStorage;
  set blockInterval(Duration duration) => _blockInterval = duration;
  set maxTransactions(int maxTransactions) =>
      _maxTransactions = maxTransactions;
  set databaseDir(String databaseDir) => _databaseDir = databaseDir;
  set address(String? address) => _address = address;

  Future<NodeService> build() async {
    KeyModel primaryKey = await _loadPrimaryKey();
    L0Storage l0Storage = SStorageService(_apiKey!, primaryKey.privateKey);
    Database database = sqlite3
        .open("$_databaseDir/${base64Url.encode(primaryKey.address)}.db");

    NodeService nodeService = NodeService()
      ..blockInterval = _blockInterval
      ..maxTransactions = _maxTransactions
      ..transactionService = TransactionService(database)
      ..blockService = BlockService(database)
      ..xchainService = XchainService(l0Storage, database)
      ..readOnly = _readOnly
      ..primaryKey = primaryKey;
    nodeService.backupService =
        BackupService(l0Storage, database, primaryKey, nodeService.getBlock);
    await nodeService.init();
    return nodeService;
  }

  Future<KeyModel> _loadPrimaryKey() async {
    if (_keyStorage == null) {
      throw Exception('Keystore must be set to build NodeService');
    }
    KeyService keyService = KeyService(_keyStorage!);
    if (_address != null) {
      KeyModel? key = await keyService.get(_address!);
      if (key != null) {
        return key;
      }
    }
    return await keyService.create();
  }
}
