/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:tiki_sdk_dart/cache/content_schema.dart';
import 'package:tiki_sdk_dart/cache/title/title_model.dart';
import 'package:tiki_sdk_dart/cache/title/title_service.dart';
import 'package:tiki_sdk_dart/node/node_service.dart';
import 'package:tiki_sdk_dart/node/transaction/transaction_model.dart';
import 'package:tiki_sdk_dart/utils/bytes.dart';
import 'package:tiki_sdk_dart/utils/compact_size.dart';

import '../../in_mem_node_service_builder.dart';

void main() {
  group('Title Service Tests', () {
    test('create - Success', () async {
      InMemNodeServiceBuilder builder = InMemNodeServiceBuilder();
      NodeService nodeService = await builder.build();
      TitleService titleService =
          TitleService('com.tiki.test', nodeService, builder.database);
      await titleService.create('create test');
      TransactionModel transaction = TransactionModel.fromMap(
          builder.database.select("SELECT * FROM txn LIMIT 1").first);

      List<Uint8List> contents = CompactSize.decode(transaction.contents);
      expect(
          Bytes.decodeBigInt(contents[0]).toInt(), ContentSchema.title.value);
      TitleModel retrieved = TitleModel.decode(contents.sublist(1));
      expect(retrieved.ptr, 'create test');
      expect(retrieved.origin, 'com.tiki.test');
    });

    test('getByPtr - Success', () async {
      InMemNodeServiceBuilder builder = InMemNodeServiceBuilder();
      NodeService nodeService = await builder.build();
      TitleService titleService =
          TitleService('com.tiki.test', nodeService, builder.database);
      Uint8List titleId =
          (await titleService.create('create test')).transactionId!;

      TitleModel? titleRecord = titleService.getByPtr('create test');
      expect(titleRecord != null, true);
      expect(Bytes.memEquals(titleRecord!.transactionId!, titleId), true);
      expect(titleRecord.ptr, 'create test');
    });

    test('getByPtr - Null', () async {
      InMemNodeServiceBuilder builder = InMemNodeServiceBuilder();
      NodeService nodeService = await builder.build();
      TitleService titleService =
          TitleService('com.tiki.test', nodeService, builder.database);
      TitleModel? titleRecord = titleService.getByPtr('NOT');
      expect(titleRecord == null, true);
    });
  });
}
