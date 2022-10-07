import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';
import 'package:tiki_sdk_dart/node/node_service.dart';
import 'package:tiki_sdk_dart/node/node_service_builder_storage.dart';
import 'package:uuid/uuid.dart';

import '../../in_mem_key.dart';
import '../../in_mem_l0_storage.dart';

main() {
  group('xchain tests', () {
    test('rebuild chain on node initialization', () async {
      List<String> contentList =
          List.generate(Random().nextInt(2000), (index) => const Uuid().v4());
      InMemL0Storage l0storage = InMemL0Storage();
      KeyStorage keyStorage = InMemKeyStorage();
      Database database = sqlite3.openInMemory();
      NodeServiceBuilderStorage builder = NodeServiceBuilderStorage();
      builder.database = database;
      builder.keyStorage = keyStorage;
      await builder.loadPrimaryKey();
      builder.l0Storage = l0storage;
      builder.blockInterval = const Duration(seconds: 1);
      NodeService node = await builder.build();
      for (int i = 0; i < contentList.length; i++) {
        node.write(Uint8List.fromList(contentList[i].codeUnits));
      }
      String xchainAddress = base64Url.encode(base64.decode(node.address));
      await shuffleBlocks(l0storage, xchainAddress);
      Database db = sqlite3.openInMemory();
      builder.database = db;
      builder.readOnly = [xchainAddress];
      NodeService nodeService2 = await builder.build();
      Map<String, Uint8List> allBlocks = await l0storage.getAll(xchainAddress);
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
      InMemL0Storage l0storage = InMemL0Storage();
      KeyStorage keyStorage = InMemKeyStorage();
      Database database = sqlite3.openInMemory();
      NodeServiceBuilderStorage builder = NodeServiceBuilderStorage();
      builder.database = database;
      builder.keyStorage = keyStorage;
      await builder.loadPrimaryKey();
      builder.l0Storage = l0storage;
      builder.blockInterval = const Duration(seconds: 1);
      NodeService node = await builder.build();
      for (int i = 0; i < contentList.length; i++) {
        node.write(Uint8List.fromList(contentList[i].codeUnits));
      }
      String xchainAddress = base64Url.encode(base64.decode(node.address));
      await shuffleBlocks(l0storage, xchainAddress);
      Database db2 = sqlite3.openInMemory();
      KeyStorage ks2 = InMemKeyStorage();
      builder.database = db2;
      builder.keyStorage = ks2;
      await builder.loadPrimaryKey();
      NodeService node2 = await builder.build();
      Map<String, Uint8List> allBlocks = await l0storage.getAll(xchainAddress);
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

    test('rebuild 3 chains on node initialization', skip: true, () async {
      List<String> readOnly = [];
      InMemL0Storage l0storage = InMemL0Storage();
      KeyStorage keyStorage = InMemKeyStorage();
      NodeServiceBuilderStorage builder = NodeServiceBuilderStorage();

      List<String> contentList =
          List.generate(Random().nextInt(2000), (index) => const Uuid().v4());
      Database database = sqlite3.openInMemory();
      builder.database = database;
      builder.keyStorage = keyStorage;
      await builder.loadPrimaryKey();
      builder.l0Storage = l0storage;
      builder.blockInterval = const Duration(seconds: 1);
      NodeService node1 = await builder.build();
      for (int i = 0; i < contentList.length; i++) {
        node1.write(Uint8List.fromList('1${contentList[i]}'.codeUnits));
      }
      readOnly.add(base64Url.encode(base64.decode(node1.address)));

      contentList =
          List.generate(Random().nextInt(2000), (index) => const Uuid().v4());
      builder.database = sqlite3.openInMemory();
      await builder.loadPrimaryKey();
      NodeService node2 = await builder.build();
      for (int i = 0; i < contentList.length; i++) {
        node2.write(Uint8List.fromList('2${contentList[i]}'.codeUnits));
      }
      readOnly.add(base64Url.encode(base64.decode(node2.address)));
      builder.database = sqlite3.openInMemory();
      builder.loadPrimaryKey();
      NodeService node3 = await builder.build();

      contentList =
          List.generate(Random().nextInt(2000), (index) => const Uuid().v4());
      for (int i = 0; i < contentList.length; i++) {
        node3.write(Uint8List.fromList('3${contentList[i]}'.codeUnits));
      }
      readOnly.add(base64Url.encode(base64.decode(node1.address)));
      builder.database = sqlite3.openInMemory();
      builder.loadPrimaryKey();
      builder.readOnly = readOnly;
      NodeService nodeService = await builder.build();
      Map<String, Uint8List> allBlocks = {};
      for (String address in readOnly) {
        allBlocks.addEntries((await l0storage.getAll(address)).entries);
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
