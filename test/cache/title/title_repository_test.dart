/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';
import 'package:tiki_trail/cache/title/title_model.dart';
import 'package:tiki_trail/cache/title/title_repository.dart';
import 'package:tiki_trail/node/transaction/transaction_repository.dart';
import 'package:tiki_trail/utils/bytes.dart';
import 'package:uuid/uuid.dart';

void main() {
  group('Title Repository Tests', () {
    test('getAll - Success', () {
      Database db = sqlite3.openInMemory();
      TransactionRepository(db);
      TitleRepository repository = TitleRepository(db);

      int numRecords = 3;
      for (int i = 0; i < numRecords; i++) {
        TitleModel record = TitleModel('com.mytiki.test', const Uuid().v4(),
            transactionId: Bytes.utf8Encode(const Uuid().v4()));
        repository.save(record);
      }

      List<TitleModel> titles = repository.getAll();
      expect(titles.length, numRecords);
    });

    test('getByPtr - Success', () {
      Database db = sqlite3.openInMemory();
      TransactionRepository(db);
      TitleRepository repository = TitleRepository(db);

      int numRecords = 3;
      Map<String, String> ptrTidMap = {};
      for (int i = 0; i < numRecords; i++) {
        String ptr = const Uuid().v4();
        String tid = const Uuid().v4();
        ptrTidMap[ptr] = tid;
        TitleModel record = TitleModel('com.mytiki.test', ptr,
            transactionId: Bytes.utf8Encode(tid));
        repository.save(record);
      }

      for (int i = 0; i < numRecords; i++) {
        TitleModel? title =
            repository.getByPtr(ptrTidMap.keys.elementAt(i), 'com.mytiki.test');
        expect(title != null, true);
        expect(Bytes.utf8Decode(title!.transactionId!),
            ptrTidMap.values.elementAt(i));
      }
    });
  });
}
