/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:typed_data';

import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';
import 'package:tiki_sdk_dart/node/block/block_repository.dart';
import 'package:tiki_sdk_dart/node/transaction/transaction_model.dart';
import 'package:tiki_sdk_dart/node/transaction/transaction_repository.dart';
import 'package:uuid/uuid.dart';

void main() {
  group('Transaction Repository Tests', () {
    test('Save - Success ', () async {
      Database database = sqlite3.openInMemory();
      BlockRepository(database);
      TransactionRepository repository = TransactionRepository(database);

      String assetRef = 'AA==';
      DateTime timestamp = DateTime.now();
      Uint8List address = Uint8List.fromList(utf8.encode(const Uuid().v4()));
      Uint8List contents = Uint8List.fromList(utf8.encode(const Uuid().v4()));
      Uint8List signature = Uint8List.fromList(utf8.encode(const Uuid().v4()));
      Uint8List id = Uint8List.fromList(utf8.encode(const Uuid().v4()));

      TransactionModel transaction = TransactionModel(
          id: id,
          address: address,
          contents: contents,
          assetRef: assetRef,
          timestamp: timestamp,
          signature: signature);

      repository.save(transaction);
      TransactionModel? found = repository.getById(id);

      expect(found != null, true);
      expect(found?.assetRef, assetRef);
      expect(found?.timestamp, timestamp.subtract(Duration(microseconds: timestamp.microsecond)));
      expect(found?.address, address);
      expect(found?.contents, contents);
      expect(found?.signature, signature);
      expect(found?.id, id);
    });
  });
}
