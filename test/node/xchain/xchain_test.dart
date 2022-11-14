/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:tiki_sdk_dart/node/node_service.dart';
import 'package:uuid/uuid.dart';

import '../../in_mem_l0_storage.dart';
import '../../in_mem_node_service_builder.dart';

main() {
  group('xchain tests', skip: true, () {
    test('rebuild chain on node initialization', () async {
      List<String> contentList =
          List.generate(Random().nextInt(2000), (index) => const Uuid().v4());
      InMemNodeServiceBuilder inMemNodeService = InMemNodeServiceBuilder();
      inMemNodeService.blockInterval = const Duration(seconds: 1);
      NodeService node = await inMemNodeService.build();
      for (int i = 0; i < contentList.length; i++) {
        node.write(Uint8List.fromList(contentList[i].codeUnits));
      }
      String xchainAddress = base64Url.encode(base64.decode(node.address));
      await shuffleBlocks(inMemNodeService.l0Storage, xchainAddress);
      InMemNodeServiceBuilder inMemNodeServiceBuilder2 =
          InMemNodeServiceBuilder();
      inMemNodeServiceBuilder2.readOnly = [xchainAddress];
      NodeService nodeService2 = await inMemNodeServiceBuilder2.build();
      Map<String, Uint8List> allBlocks =
          await inMemNodeService.l0Storage.getAll(xchainAddress);
      expect(allBlocks.isEmpty, false);
      List<String> blockIds = allBlocks.keys.toList();
      for (String id in blockIds) {
        if (id == 'public.key') continue;
        Uint8List blkId =
            base64Url.decode(id.split('/').last.replaceFirst('.block', ''));
        Uint8List? block = nodeService2.getBlock(blkId);
        expect(block != null, true);
      }
    });

    test('update chain with new blocks, skip cached', () async {
      List<String> contentList =
          List.generate(Random().nextInt(2000), (index) => const Uuid().v4());
      InMemNodeServiceBuilder inMemNodeServiceBuilder =
          InMemNodeServiceBuilder();
      inMemNodeServiceBuilder.blockInterval = const Duration(seconds: 1);
      NodeService node = await inMemNodeServiceBuilder.build();
      for (int i = 0; i < contentList.length; i++) {
        node.write(Uint8List.fromList(contentList[i].codeUnits));
      }
      String xchainAddress = base64Url.encode(base64.decode(node.address));
      await shuffleBlocks(inMemNodeServiceBuilder.l0Storage, xchainAddress);
      NodeService node2 = await InMemNodeServiceBuilder().build();
      Map<String, Uint8List> allBlocks =
          await inMemNodeServiceBuilder.l0Storage.getAll(xchainAddress);
      expect(allBlocks.isEmpty, false);
      List<String> blockIds = allBlocks.keys.toList();
      for (String id in blockIds) {
        if (id == 'public.key') continue;
        Uint8List blkId =
            base64Url.decode(id.split('/').last.replaceFirst('.block', ''));
        Uint8List? block = node2.getBlock(blkId);
        expect(block != null, true);
      }
    });

    test('rebuild 3 chains on node initialization', () async {
      List<String> readOnly = [];
      List<String> contentList =
          List.generate(Random().nextInt(2000), (index) => const Uuid().v4());
      InMemNodeServiceBuilder inMemNodeServiceBuilder =
          InMemNodeServiceBuilder();
      inMemNodeServiceBuilder.blockInterval = const Duration(seconds: 1);
      NodeService node1 = await inMemNodeServiceBuilder.build();
      for (int i = 0; i < contentList.length; i++) {
        node1.write(Uint8List.fromList('1${contentList[i]}'.codeUnits));
      }
      readOnly.add(base64Url.encode(base64.decode(node1.address)));

      contentList =
          List.generate(Random().nextInt(2000), (index) => const Uuid().v4());

      NodeService node2 = await InMemNodeServiceBuilder().build();
      for (int i = 0; i < contentList.length; i++) {
        node2.write(Uint8List.fromList('2${contentList[i]}'.codeUnits));
      }
      readOnly.add(base64Url.encode(base64.decode(node2.address)));
      NodeService node3 = await InMemNodeServiceBuilder().build();

      contentList =
          List.generate(Random().nextInt(2000), (index) => const Uuid().v4());
      for (int i = 0; i < contentList.length; i++) {
        node3.write(Uint8List.fromList('3${contentList[i]}'.codeUnits));
      }
      readOnly.add(base64Url.encode(base64.decode(node1.address)));
      NodeService nodeService = await InMemNodeServiceBuilder().build();
      Map<String, Uint8List> allBlocks = {};
      for (String address in readOnly) {
        allBlocks.addEntries(
            (await inMemNodeServiceBuilder.l0Storage.getAll(address)).entries);
      }
      expect(allBlocks.isEmpty, false);
      List<String> blockIds = allBlocks.keys.toList();
      for (String id in blockIds) {
        if (id == 'public.key') continue;
        Uint8List blkId =
            base64Url.decode(id.split('/').last.replaceFirst('.block', ''));
        Uint8List? block = nodeService.getBlock(blkId);
        expect(block != null, true);
      }
    });
  });
}

Future<void> shuffleBlocks(InMemL0Storage storage, String address) async {
  Map<String, Uint8List> allBlocks = {};
  allBlocks = await storage.getAll(address);
  List<String> blockIds = allBlocks.keys.toList();
  blockIds.shuffle();
  Map<String, Uint8List> newStorage = {};
  for (String id in blockIds) {
    newStorage[id] = allBlocks[id]!;
  }
  storage.storage[address] = newStorage;
}
