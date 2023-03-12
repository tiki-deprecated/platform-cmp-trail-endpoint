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
import 'package:tiki_sdk_dart/node/transaction/transaction_model.dart';
import 'package:tiki_sdk_dart/node/transaction/transaction_repository.dart';
import 'package:uuid/uuid.dart';

void main() {
  group('Transaction Repository Tests', () {
    test('Save/GetById - Success ', () async {
      Database database = sqlite3.openInMemory();
      BlockRepository(database);
      TransactionRepository repository = TransactionRepository(database);

      String assetRef = '';
      DateTime timestamp = DateTime.now();
      Uint8List address = Uint8List.fromList(utf8.encode(const Uuid().v4()));
      Uint8List contents = Uint8List.fromList(utf8.encode(const Uuid().v4()));
      Uint8List signature = Uint8List.fromList(utf8.encode(const Uuid().v4()));
      Uint8List id = Uint8List.fromList(utf8.encode(const Uuid().v4()));

      TransactionModel transaction = TransactionModel(
          id: id,
          version: 1,
          address: address,
          contents: contents,
          assetRef: assetRef,
          timestamp: timestamp,
          signature: signature);

      repository.save(transaction);
      TransactionModel? found = repository.getById(id);

      expect(found != null, true);
      expect(found?.assetRef, assetRef);
      expect(found?.version, 1);
      expect(found?.timestamp,
          timestamp.subtract(Duration(microseconds: timestamp.microsecond)));
      expect(found?.address, address);
      expect(found?.contents, contents);
      expect(found?.signature, signature);
      expect(found?.id, id);
    });

    test('Commit/GetByBlockId - Success ', () async {
      Database database = sqlite3.openInMemory();
      BlockRepository blockRepository = BlockRepository(database);
      TransactionRepository repository = TransactionRepository(database);

      String assetRef = '';
      DateTime timestamp = DateTime.now();
      Uint8List address = Uint8List.fromList(utf8.encode(const Uuid().v4()));
      Uint8List contents = Uint8List.fromList(utf8.encode(const Uuid().v4()));
      Uint8List signature = Uint8List.fromList(utf8.encode(const Uuid().v4()));
      Uint8List id = Uint8List.fromList(utf8.encode(const Uuid().v4()));

      TransactionModel transaction = TransactionModel(
          id: id,
          version: 1,
          address: address,
          contents: contents,
          assetRef: assetRef,
          timestamp: timestamp,
          signature: signature);

      repository.save(transaction);

      Uint8List previousHash =
          Uint8List.fromList(utf8.encode(const Uuid().v4()));
      Uint8List transactionRoot =
          Uint8List.fromList(utf8.encode(const Uuid().v4()));
      Uint8List blockId = Uint8List.fromList(utf8.encode(const Uuid().v4()));
      Uint8List merkelProof =
          Uint8List.fromList(utf8.encode(const Uuid().v4()));

      BlockModel block = BlockModel(
          id: blockId,
          previousHash: previousHash,
          transactionRoot: transactionRoot);

      blockRepository.save(block);
      transaction.block = block;
      transaction.merkelProof = merkelProof;

      repository.commit(transaction.id!, block, merkelProof);

      List<TransactionModel> found = repository.getByBlockId(blockId);

      expect(found.length, 1);
      expect(found.elementAt(0).assetRef, assetRef);
      expect(found.elementAt(0).version, 1);
      expect(found.elementAt(0).timestamp,
          timestamp.subtract(Duration(microseconds: timestamp.microsecond)));
      expect(found.elementAt(0).address, address);
      expect(found.elementAt(0).contents, contents);
      expect(found.elementAt(0).signature, signature);
      expect(found.elementAt(0).id, id);
      expect(found.elementAt(0).block?.id, blockId);
      expect(found.elementAt(0).merkelProof, merkelProof);
    });
  });
}
