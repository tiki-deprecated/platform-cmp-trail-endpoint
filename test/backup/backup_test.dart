/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:math';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:tiki_sdk_dart/src/node/backup/backup_block.dart';
import 'package:tiki_sdk_dart/src/node/backup/backup_repository.dart';
import 'package:tiki_sdk_dart/src/node/block/block_model.dart';
import 'package:tiki_sdk_dart/src/node/block/block_repository.dart';
import 'package:tiki_sdk_dart/src/node/xchain/xchain_model.dart';
import 'package:tiki_sdk_dart/src/node/xchain/xchain_repository.dart';

void main() {
  final db = sqlite3.openInMemory();
  group('backup repository tests', () {
    BackupRepository repository = BackupRepository(db);
    BlockRepository blkRepository = BlockRepository(db);
    XchainRepository xcRepository = XchainRepository(db: db);
    XchainModel xchain = XchainModel(id: 123, pubkey: 'a', uri: 'teste');
    xcRepository.save(xchain);
    BlockModel blk = BlockModel(
        seq: 123,
        version: 1,
        previousHash: Uint8List.fromList(
            List.generate(50, (index) => Random().nextInt(33) + 89)),
        xchain: xchain,
        transactionRoot: Uint8List(1),
        transactionCount: 0,
        timestamp: DateTime.now());
    blkRepository.save(blk);
    test('save bkps, retrieve all', () {
      BackupModel bkp1 = _generateBackupModel(blk);
      BackupModel bkp2 = _generateBackupModel(blk);
      BackupModel bkp3 = _generateBackupModel(blk);
      repository.save(bkp1);
      repository.save(bkp2);
      repository.save(bkp3);
      expect(1, 1);
      List<BackupModel> bkps = repository.getAll();
      expect(bkps.length, 3);
    });
  });
}

BackupModel _generateBackupModel(BlockModel block) =>
    BackupModel(signature: 'dsa', timestamp: DateTime.now(), payload: block);
