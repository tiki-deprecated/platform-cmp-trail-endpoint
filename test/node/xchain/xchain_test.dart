import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';
import 'package:tiki_sdk_dart/node/l0_storage.dart';
import 'package:tiki_sdk_dart/node/node_service.dart';
import 'package:uuid/uuid.dart';

import '../../in_mem_key.dart';
import '../../in_mem_l0_storage.dart';

main() {
  group('xchain tests', () {
    Database db = sqlite3.openInMemory();
    InMemKeyStorage keyStorage = InMemKeyStorage();
    InMemL0Storage storage = InMemL0Storage();
    KeyService keysService = KeyService(keyStorage);
    TransactionService transactionService = TransactionService(db);
    BlockService blockService = BlockService(db);
    List<String> contentList =
        List.generate(Random().nextInt(2000), (index) => const Uuid().v4());
    String xchainAddress = '';

    Future<void> createChain(
        BlockService blockService,
        TransactionService transactionService,
        KeyService keyService,
        L0Storage storage,
        Database database) async {
      NodeService nodeService = await NodeService().init(
          db, InMemKeyStorage(), storage,
          blockInterval: const Duration(seconds: 1));

      for (int i = 0; i < contentList.length; i++) {
        nodeService.write(Uint8List.fromList(contentList[i].codeUnits));
      }
      xchainAddress = base64Url.encode(base64.decode(nodeService.address));
    }

    test('get all blocks and rebuild chain', () async {
      await createChain(
          blockService, transactionService, keysService, storage, db);
      await shuffleBlocks(storage, xchainAddress);
      db = sqlite3.openInMemory();
      NodeService nodeService = await NodeService()
          .init(db, InMemKeyStorage(), storage, readOnly: [xchainAddress]);
      Map<String, Uint8List> allBlocks = await storage.getAll(xchainAddress);
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
