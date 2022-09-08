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
import 'package:tiki_sdk_dart/src/node/block/block_repository.dart';
import 'package:tiki_sdk_dart/src/node/keys/keys_model.dart';
import 'package:tiki_sdk_dart/src/node/keys/keys_service.dart';
import 'package:tiki_sdk_dart/src/utils/mem_keys_store.dart';

void main() async {
  final db = sqlite3.openInMemory();
  KeysService _keysService = KeysService(MemSecureStorageStrategy());
  KeysModel keys = await _keysService.create();
  group('backup tests', () {
    BackupRepository repository = BackupRepository(db);
    BlockRepository blkRepository = BlockRepository(db);
    BlockModel blk = BlockModel(
        version: 1,
        previousHash: Uint8List.fromList(
            List.generate(50, (index) => Random().nextInt(33) + 89)),
        transactionRoot: Uint8List(1),
        transactionCount: 0,
        timestamp: DateTime.now());
    blk.id = Digest("SHA3-256").process(_blockService.header(blk));
    //blkRepository.save(blk);
    test('save bkps, retrieve all', () {
      BackupModel bkp1 = _generateBackupModel(blk, keys);
      BackupModel bkp2 = _generateBackupModel(blk, keys);
      BackupModel bkp3 = _generateBackupModel(blk, keys);
      repository.save(bkp1);
      repository.save(bkp2);
      repository.save(bkp3);
      expect(1, 1);
      ResultSet bkps = db.select('SELECT * FROM ${BlockRepository.table};');
      expect(bkps.rows, 3);
    });
  });
}

BackupModel _generateBackupModel(BlockModel block, KeysModel signKey) =>
    BackupModel(
        signKey: signKey.privateKey,
        assetRef: 'tiki://${base64Url.encode(signKey.address)}/${base64Url.encode(block.id!)}',
        payload: block.toJson());
