/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:math';
import 'dart:typed_data';

import 'dart:convert';

import 'package:test/test.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:tiki_sdk_dart/src/node/block/block_model.dart';
import 'package:tiki_sdk_dart/src/node/block/block_repository.dart';
import 'package:tiki_sdk_dart/src/node/transaction/transaction_model.dart';
import 'package:tiki_sdk_dart/src/node/xchain/xchain_model.dart';
import 'package:tiki_sdk_dart/src/node/xchain/xchain_repository.dart';
import 'package:tiki_sdk_dart/src/utils/page_model.dart';
import 'package:tiki_sdk_dart/src/utils/utils.dart';

void main() {
  final db = sqlite3.openInMemory();
  group('block repository tests', () {
    BlockRepository repository = BlockRepository(db);
    XchainRepository xcRepository = XchainRepository(db);
    XchainModel xchain = XchainModel(id: 123, uri: 'teste', pubkey: '123');
    xcRepository.save(xchain);
    test('save blocks, retrieve all', () {
      BlockModel block1 = _generateBlockModel();
      BlockModel block2 = _generateBlockModel();
      BlockModel block3 = _generateBlockModel();
      repository.save(block1);
      repository.save(block2);
      repository.save(block3);
      expect(1, 1);
      PageModel<BlockModel> blocks = repository.getAll(xchain);
      expect(blocks.items.length, 3);
    });

    test('serialize, deserialize', () {
      TransactionModel original = TransactionModel(
          version: 1,
          address: 'abc',
          timestamp: DateTime(2022),
          assetRef: 'test://test_chain/',
          contents: Uint8List.fromList('hello world'.codeUnits));
      Uint8List serialized = original.serialize();
      TransactionModel deserialized = TransactionModel.deserialize(serialized);
      expect(original.version, deserialized.version);
      expect(original.address, deserialized.address);
      expect(original.assetRef, deserialized.assetRef);
      expect(original.signature, deserialized.signature);
      expect(original.contents, deserialized.contents);
    });
  });
}

BlockModel _generateBlockModel() => BlockModel(
    version: 1,
    previousHash: String.fromCharCodes(
        List.generate(50, (index) => Random().nextInt(33) + 89)),
    xchain: XchainModel(id: 123, uri: 'teste', pubkey: '123'),
    transactionRoot: Uint8List.fromList(''.codeUnits),
    transactionCount: 0,
    timestamp: DateTime.now());
