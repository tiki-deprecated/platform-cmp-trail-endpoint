/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */
import 'dart:convert';
import 'dart:typed_data';

import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';
import 'package:tiki_trail/node/block/block_model.dart';
import 'package:tiki_trail/node/block/block_service.dart';
import 'package:uuid/uuid.dart';

void main() {
  group('Block Service Tests', () {
    test('Create/Commit/Get - Genesis - Success', () {
      Database database = sqlite3.openInMemory();
      BlockService service = BlockService(database);

      Uint8List transactionRoot =
          Uint8List.fromList(utf8.encode(const Uuid().v4()));

      BlockModel block = service.create(transactionRoot);
      service.commit(block);
      BlockModel? found = service.get(block.id!);

      expect(found != null, true);
      expect(found?.version, 1);
      expect(
          found?.timestamp,
          block.timestamp
              .subtract(Duration(microseconds: block.timestamp.microsecond)));
      expect(found?.id, block.id);
      expect(found?.transactionRoot, transactionRoot);
      expect(found?.previousHash, Uint8List(1));
    });

    test('Create/Commit/Get - Append - Success', () {
      Database database = sqlite3.openInMemory();
      BlockService service = BlockService(database);

      BlockModel genesis =
          service.create(Uint8List.fromList(utf8.encode(const Uuid().v4())));
      service.commit(genesis);
      BlockModel second =
          service.create(Uint8List.fromList(utf8.encode(const Uuid().v4())));
      service.commit(second);

      BlockModel? found = service.get(second.id!);

      expect(found != null, true);
      expect(found?.previousHash, genesis.id);
    });
  });
}
