import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';
import 'package:tiki_sdk_dart/node/node_service.dart';
import 'package:uuid/uuid.dart';

import '../../in_mem_key.dart';
import '../../in_mem_l0_storage.dart';

main() {
  group('xchain tests', () {
    test('rebuild chain on node initialization', () async {
      Database db = sqlite3.openInMemory();
      InMemKeyStorage keyStorage = InMemKeyStorage();
      InMemL0Storage storage = InMemL0Storage();
      List<String> contentList =
          List.generate(Random().nextInt(2000), (index) => const Uuid().v4());
      NodeService nodeService1 = await NodeService().init(
          db, keyStorage, storage,
          blockInterval: const Duration(seconds: 1));
      for (int i = 0; i < contentList.length; i++) {
        nodeService1.write(Uint8List.fromList(contentList[i].codeUnits));
      }
      String xchainAddress =
          base64Url.encode(base64.decode(nodeService1.address));
      await shuffleBlocks(storage, xchainAddress);
      db = sqlite3.openInMemory();
      NodeService nodeService2 = await NodeService()
          .init(db, keyStorage, storage, readOnly: [xchainAddress]);
      Map<String, Uint8List> allBlocks = await storage.getAll(xchainAddress);
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
      Database db = sqlite3.openInMemory();
      InMemL0Storage storage = InMemL0Storage();
      List<String> contentList =
          List.generate(Random().nextInt(2000), (index) => const Uuid().v4());
      NodeService nodeService1 = await NodeService().init(
          db, InMemKeyStorage(), storage,
          blockInterval: const Duration(seconds: 1));
      for (int i = 0; i < contentList.length; i++) {
        nodeService1.write(Uint8List.fromList(contentList[i].codeUnits));
      }
      String xchainAddress =
          base64Url.encode(base64.decode(nodeService1.address));
      await shuffleBlocks(storage, xchainAddress);

      Database db2 = sqlite3.openInMemory();
      KeyStorage ks2 = InMemKeyStorage();
      NodeService nodeService2 = await NodeService()
          .init(db2, ks2, storage, readOnly: [xchainAddress]);
      Map<String, Uint8List> allBlocks = await storage.getAll(xchainAddress);
      expect(allBlocks.isEmpty, false);
      List<String> blockIds = allBlocks.keys.toList();
      for (String id in blockIds) {
        if (id == 'public.key') continue;
        Uint8List blkId =
            base64Url.decode(id.split('/').last.replaceFirst('.block', ''));
        Uint8List? block = nodeService2.getBlock(blkId);
        expect(block != null, true);
      }

      for (int i = 0; i < contentList.length; i++) {
        nodeService1
            .write(Uint8List.fromList(('1${contentList[i]}').codeUnits));
      }
      await shuffleBlocks(storage, xchainAddress);

      nodeService2 = await NodeService()
          .init(db2, ks2, storage, readOnly: [xchainAddress]);
      allBlocks = await storage.getAll(xchainAddress);
      expect(allBlocks.isEmpty, false);
      blockIds = allBlocks.keys.toList();
      for (String id in blockIds) {
        if (id == 'public.key') continue;
        Uint8List blkId =
            base64Url.decode(id.split('/').last.replaceFirst('.block', ''));
        Uint8List? block = nodeService2.getBlock(blkId);
        expect(block != null, true);
      }
    });

    test('rebuild 3 chains on node initialization', () async {
      List<String> readOnly = [];
      Database db = sqlite3.openInMemory();
      InMemKeyStorage keyStorage = InMemKeyStorage();
      InMemL0Storage storage = InMemL0Storage();
      List<String> contentList =
          List.generate(Random().nextInt(2000), (index) => const Uuid().v4());
      NodeService nodeService1 = await NodeService().init(
          db, keyStorage, storage,
          blockInterval: const Duration(seconds: 1));
      for (int i = 0; i < contentList.length; i++) {
        nodeService1.write(Uint8List.fromList('1${contentList[i]}'.codeUnits));
      }
      readOnly.add(base64Url.encode(base64.decode(nodeService1.address)));
      db = sqlite3.openInMemory();
      contentList =
          List.generate(Random().nextInt(2000), (index) => const Uuid().v4());
      NodeService nodeService2 = await NodeService().init(
          db, keyStorage, storage,
          blockInterval: const Duration(seconds: 1));
      for (int i = 0; i < contentList.length; i++) {
        nodeService2.write(Uint8List.fromList('2${contentList[i]}'.codeUnits));
      }
      readOnly.add(base64Url.encode(base64.decode(nodeService1.address)));
      db = sqlite3.openInMemory();
      NodeService nodeService3 = await NodeService().init(
          db, keyStorage, storage,
          blockInterval: const Duration(seconds: 1));
      contentList =
          List.generate(Random().nextInt(2000), (index) => const Uuid().v4());
      for (int i = 0; i < contentList.length; i++) {
        nodeService3.write(Uint8List.fromList('3${contentList[i]}'.codeUnits));
      }
      readOnly.add(base64Url.encode(base64.decode(nodeService1.address)));
      db = sqlite3.openInMemory();
      NodeService nodeService =
          await NodeService().init(db, keyStorage, storage, readOnly: readOnly);
      Map<String, Uint8List> allBlocks = {};
      for (String address in readOnly) {
        allBlocks.addEntries((await storage.getAll(address)).entries);
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
