/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:async';

import 'package:sqlite3/sqlite3.dart';
import '../shared_storage/shared_storage.dart';
import 'node_service.dart';
import 'node_service_builder_base.dart';
import 'xchain/xchain_service.dart';

import 'l0_storage.dart';

export './backup/backup_service.dart';
export './block/block_service.dart';
export './key/key_service.dart';
export './transaction/transaction_service.dart';
export '../shared_storage/wasabi/wasabi_service.dart';

class NodeServiceBuilderStorage extends NodeServiceBuilderBase {
  KeyModel? _primaryKey;
  L0Storage? _l0Storage;
  Database? _database;
  KeyStorage? _keyStorage;

  List<String> _readOnly = [];
  Duration _blockInterval = const Duration(minutes: 1);
  int _maxTransactions = 200;

  set database(Database val) => _database = val;
  set l0Storage(L0Storage val) => _l0Storage = val;
  set readOnly(List<String> val) => _readOnly = val;
  set keyStorage(KeyStorage val) => _keyStorage = val;
  set blockInterval(Duration val) => _blockInterval = val;
  set maxTransactions(int val) => _maxTransactions = val;

  @override
  Future<NodeService> build() async {
    if (_l0Storage == null) throw Exception('L0Storage must be set');
    if (_primaryKey == null) throw Exception('Primary key should be loaded');
    _database ??= sqlite3.openInMemory();
    nodeService = NodeService();
    nodeService.blockInterval = _blockInterval;
    nodeService.maxTransactions = _maxTransactions;
    nodeService.transactionService = TransactionService(_database!);
    nodeService.blockService = BlockService(_database!);
    nodeService.xchainService = XchainService(_l0Storage!, _database!);
    nodeService.backupService = BackupService(
        _l0Storage!, _database!, _primaryKey!, nodeService.getBlock);
    nodeService.readOnly = _readOnly;
    nodeService.primaryKey = _primaryKey!;
    await nodeService.init();
    return nodeService;
  }

  Future<void> loadStorage(String apiId) async {
    if (_primaryKey == null) {
      throw Exception('Load primary Key before loading Storage');
    }
    _l0Storage = SharedStorage(apiId, _primaryKey!.privateKey);
  }

  @override
  Future<void> loadPrimaryKey([String? address]) async {
    if (_keyStorage == null) {
      throw Exception('Set KeyStorage before loading primary key');
    }
    KeyService keyService = KeyService(_keyStorage!);
    if (address != null) {
      KeyModel? key = await keyService.get(address);
      if (key != null) {
        _primaryKey = key;
        return;
      }
    }
    _primaryKey = await keyService.create();
    return;
  }
}
