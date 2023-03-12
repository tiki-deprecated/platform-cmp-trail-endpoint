/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:typed_data';

import 'package:sqlite3/common.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';
import 'package:tiki_sdk_dart/node/xchain/xchain_model.dart';
import 'package:tiki_sdk_dart/node/xchain/xchain_repository.dart';
import 'package:tiki_sdk_dart/utils/bytes.dart';
import 'package:uuid/uuid.dart';

void main() {
  group('XChain Repository tests', () {
    test('Save - Success', () async {
      CommonDatabase database = sqlite3.openInMemory();
      XChainRepository repository = XChainRepository(database);

      XChainModel xChainModel = XChainModel(const Uuid().v4(),
          address: Uint8List.fromList(utf8.encode(const Uuid().v4())),
          blockId: Uint8List.fromList(utf8.encode(const Uuid().v4())),
          fetchedOn: DateTime.now());

      repository.save(xChainModel);
    });

    test('GetAllByAddress - Success', () async {
      CommonDatabase database = sqlite3.openInMemory();
      XChainRepository repository = XChainRepository(database);

      int numRecords = 3;
      Uint8List address = Uint8List.fromList(utf8.encode(const Uuid().v4()));
      List<String> blockIds = [];
      for (int i = 0; i < numRecords; i++) {
        Uint8List blockId = Uint8List.fromList(utf8.encode(const Uuid().v4()));
        blockIds.add(Bytes.base64UrlEncode(blockId));
        XChainModel xChainModel = XChainModel(const Uuid().v4(),
            address: address, blockId: blockId, fetchedOn: DateTime.now());
        repository.save(xChainModel);
      }
      List<XChainModel> xcs = repository.getAllByAddress(address);
      expect(xcs.length, 3);
      for (int i = 0; i < numRecords; i++) {
        expect(Bytes.base64UrlEncode(xcs.elementAt(i).address!),
            Bytes.base64UrlEncode(address));
        expect(
            blockIds.contains(Bytes.base64UrlEncode(xcs.elementAt(i).blockId!)),
            true);
      }
    });
  });
}
