/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:typed_data';

import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';
import 'package:tiki_sdk_dart/node/block/block_model.dart';
import 'package:tiki_sdk_dart/node/block/block_repository.dart';
import 'package:uuid/uuid.dart';

void main() {
  group('Block Repository Tests', () {
    test('Save/GetById - Success ', () async {
      Database database = sqlite3.openInMemory();
      BlockRepository repository = BlockRepository(database);

      DateTime timestamp = DateTime.now();
      Uint8List previousHash =
          Uint8List.fromList(utf8.encode(const Uuid().v4()));
      Uint8List transactionRoot =
          Uint8List.fromList(utf8.encode(const Uuid().v4()));
      Uint8List id = Uint8List.fromList(utf8.encode(const Uuid().v4()));

      BlockModel block = BlockModel(
          id: id,
          version: 1,
          previousHash: previousHash,
          transactionRoot: transactionRoot,
          timestamp: timestamp);

      repository.save(block);

      BlockModel? found = repository.getById(id);

      expect(found != null, true);
      expect(found?.version, 1);
      expect(found?.previousHash, previousHash);
      expect(found?.id, id);
      expect(found?.transactionRoot, transactionRoot);
    });

    test('Last - Success ', () async {
      Database database = sqlite3.openInMemory();
      BlockRepository repository = BlockRepository(database);

      DateTime timestamp = DateTime.now();
      Uint8List previousHash =
          Uint8List.fromList(utf8.encode(const Uuid().v4()));
      Uint8List transactionRoot =
          Uint8List.fromList(utf8.encode(const Uuid().v4()));
      Uint8List id = Uint8List.fromList(utf8.encode(const Uuid().v4()));

      BlockModel block = BlockModel(
          id: id,
          version: 1,
          previousHash: previousHash,
          transactionRoot: transactionRoot,
          timestamp: timestamp);

      repository.save(block);

      BlockModel? last = repository.getLast();

      expect(last != null, true);
      expect(last?.version, 1);
      expect(last?.previousHash, previousHash);
      expect(last?.id, id);
      expect(last?.transactionRoot, transactionRoot);
    });
  });
}
