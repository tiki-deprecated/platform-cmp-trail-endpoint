/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:tiki_trail/cache/content_schema.dart';
import 'package:tiki_trail/cache/title/title_model.dart';
import 'package:tiki_trail/cache/title/title_service.dart';
import 'package:tiki_trail/node/node_service.dart';
import 'package:tiki_trail/node/transaction/transaction_model.dart';
import 'package:tiki_trail/utils/bytes.dart';
import 'package:tiki_trail/utils/compact_size.dart';

import '../../fixtures/in_mem.dart';

void main() {
  group('Title Service Tests', () {
    test('create - Success', () async {
      NodeService nodeService = await InMemBuilders.nodeService();
      TitleService titleService =
          TitleService('com.tiki.test', nodeService.database, nodeService);
      await titleService.create('create test');
      TransactionModel transaction = TransactionModel.fromMap(
          nodeService.database.select("SELECT * FROM txn LIMIT 1").first);

      List<Uint8List> contents = CompactSize.decode(transaction.contents);
      expect(
          Bytes.decodeBigInt(contents[0]).toInt(), ContentSchema.title.value);
      TitleModel retrieved = TitleModel.decode(contents.sublist(1));
      expect(retrieved.ptr, 'create test');
      expect(retrieved.origin, 'com.tiki.test');
    });

    test('getByPtr - Success', () async {
      NodeService nodeService = await InMemBuilders.nodeService();
      TitleService titleService =
          TitleService('com.tiki.test', nodeService.database, nodeService);
      Uint8List titleId =
          (await titleService.create('create test')).transactionId!;

      TitleModel? titleRecord = titleService.getByPtr('create test');
      expect(titleRecord != null, true);
      expect(Bytes.memEquals(titleRecord!.transactionId!, titleId), true);
      expect(titleRecord.ptr, 'create test');
    });

    test('getByPtr - Null', () async {
      NodeService nodeService = await InMemBuilders.nodeService();
      TitleService titleService =
          TitleService('com.tiki.test', nodeService.database, nodeService);
      TitleModel? titleRecord = titleService.getByPtr('NOT');
      expect(titleRecord == null, true);
    });
  });
}
