/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/pointycastle.dart';
import 'package:test/test.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:tiki_sdk_dart/src/node/backup/backup_model.dart';
import 'package:tiki_sdk_dart/src/node/backup/backup_repository.dart';
import 'package:tiki_sdk_dart/src/node/block/block_model.dart';
import 'package:tiki_sdk_dart/src/node/block/block_service.dart';
import 'package:tiki_sdk_dart/src/node/keys/keys_model.dart';
import 'package:tiki_sdk_dart/src/node/keys/keys_service.dart';
import 'package:tiki_sdk_dart/src/utils/mem_keys_store.dart';

void main() async {
  final db = sqlite3.openInMemory();
  KeysService keysService = KeysService(MemSecureStorageStrategy());
  KeysModel keys = await keysService.create();
  group('backup tests', () {
    test('backup repository test, retrieve all', () {
      BackupRepository repository = BackupRepository(db);
      BlockService blockService = BlockService(db);
      BlockModel blk = BlockModel(
          version: 1,
          previousHash: Uint8List.fromList(
              List.generate(50, (index) => Random().nextInt(33) + 89)),
          transactionRoot: Uint8List(1),
          transactionCount: 0,
          timestamp: DateTime.now());
      blk.id = Digest("SHA3-256").process(blk.header());
      BackupModel bkp1 = _generateBackupModel(blk, keys);
      BackupModel bkp2 = _generateBackupModel(blk, keys);
      BackupModel bkp3 = _generateBackupModel(blk, keys);
      repository.save(bkp1);
      repository.save(bkp2);
      repository.save(bkp3);
      expect(1, 1);
      ResultSet bkps = db.select('SELECT * FROM ${BackupRepository.table};');
      expect(bkps.rows.length, 3);
    });

    test('write block to remote storage and retrieve', () {
      
    });
  });
}

BackupModel _generateBackupModel(BlockModel block, KeysModel signKey) =>
    BackupModel(
      path: base64Url.encode(block.id!),
    );
