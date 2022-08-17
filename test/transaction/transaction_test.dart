/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:math';

import 'package:test/test.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:tiki_sdk_dart/src/node/block/block_model.dart';
import 'package:tiki_sdk_dart/src/node/block/block_repository.dart';
import 'package:tiki_sdk_dart/src/node/xchain/xchain_model.dart';
import 'package:tiki_sdk_dart/src/node/xchain/xchain_repository.dart';

void main() {
  final db = sqlite3.openInMemory();
  group('block repository tests', () {
    BlockRepository repository = BlockRepository(db);
    XchainRepository xc_repository = XchainRepository(db);
    XchainModel xchain = XchainModel(id: 123, uri: 'teste');
    xc_repository.save(xchain);
    test('save blocks, retrieve all', () {
      BlockModel block1 = _generateBlockModel();
      BlockModel block2 = _generateBlockModel();
      BlockModel block3 = _generateBlockModel();
      repository.save(block1);
      repository.save(block2);
      repository.save(block3);
      expect(1, 1);
      List<BlockModel> chains = repository.getAll(xchain);
      expect(chains.length, 3);
    });
  });
}

BlockModel _generateBlockModel() => BlockModel(
    version: 1,
    previousHash: String.fromCharCodes(
        List.generate(50, (index) => Random().nextInt(33) + 89)),
    xchain: XchainModel(id: 123, uri: 'teste'),
    transactionRoot: '',
    transactionCount: 0,
    timestamp: DateTime.now());
