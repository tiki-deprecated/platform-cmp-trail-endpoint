/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/pointycastle.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';
import 'package:tiki_sdk_dart/node/backup/backup_model.dart';
import 'package:tiki_sdk_dart/node/backup/backup_repository.dart';
import 'package:tiki_sdk_dart/node/block/block_service.dart';
import 'package:tiki_sdk_dart/node/keys/key_service.dart';

import '../../in_mem_keys.dart';

void main() async {
  final db = sqlite3.openInMemory();
  KeysService keysService = KeysService(InMemoryKeys());
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

    test('write block to remote storage and retrieve', () {});
  });
}

BackupModel _generateBackupModel(BlockModel block, KeysModel signKey) =>
    BackupModel(
      path: base64Url.encode(block.id!),
    );
