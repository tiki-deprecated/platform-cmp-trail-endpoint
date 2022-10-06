import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/api.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';
import 'package:tiki_sdk_dart/node/l0_storage.dart';
import 'package:tiki_sdk_dart/node/node_service.dart';
import 'package:tiki_sdk_dart/node/node_service_builder_storage.dart';
import 'package:tiki_sdk_dart/utils/rsa/rsa.dart';
import 'package:uuid/uuid.dart';

import '../in_mem_key.dart';
import '../in_mem_l0_storage.dart';

void main() {
  group('Node tests', () {
    test('Init - No Primary - Success ', () async {
      L0Storage l0storage = InMemL0Storage();
      KeyStorage keyStorage = InMemKeyStorage();
      Database database = sqlite3.openInMemory();
      NodeServiceBuilderStorage builder = NodeServiceBuilderStorage();
      builder.database = database;
      builder.keyStorage = keyStorage;
      await builder.loadPrimaryKey();
      builder.l0Storage = l0storage;
      NodeService node = await builder.build();
      Uint8List address = base64Decode(node.address);
      Uint8List? publicKey =
          await l0storage.read('${base64Url.encode(address)}/public.key');

      expect(publicKey != null, true);
      expect(Digest("SHA3-256").process(publicKey!), address);

      KeyService keyService = KeyService(keyStorage);
      KeyModel? key = await keyService.get(node.address);
      RsaPublicKey rsaPublicKey = RsaPublicKey.decode(base64.encode(publicKey));

      expect(key != null, true);
      expect(rsaPublicKey, key?.privateKey.public);

      await Future.delayed(const Duration(seconds: 3));

      BlockRepository blockRepository = BlockRepository(database);
      TransactionRepository transactionRepository =
          TransactionRepository(database);

      BlockModel? last = blockRepository.getLast();
      List<TransactionModel> pending = transactionRepository.getByBlockId(null);

      expect(last == null, true);
      expect(pending.isEmpty, true);
    });

    test('Write - Success ', () async {
      L0Storage l0storage = InMemL0Storage();
      KeyStorage keyStorage = InMemKeyStorage();
      Database database = sqlite3.openInMemory();
      NodeServiceBuilderStorage builder = NodeServiceBuilderStorage();
      builder.database = database;
      builder.keyStorage = keyStorage;
      await builder.loadPrimaryKey();
      builder.l0Storage = l0storage;
      builder.blockInterval = const Duration(seconds: 1);
      NodeService node = await builder.build();
      TransactionModel tx =
          await node.write(Uint8List.fromList(utf8.encode(const Uuid().v4())));

      expect(tx.id != null, true);
      expect(tx.signature != null, true);

      TransactionRepository transactionRepository =
          TransactionRepository(database);
      List<TransactionModel> pending = transactionRepository.getByBlockId(null);
      expect(pending.length, 1);

      await Future.delayed(const Duration(seconds: 3));

      BlockRepository blockRepository = BlockRepository(database);
      BlockModel? last = blockRepository.getLast();
      expect(last != null, true);
      expect(last?.id != null, true);

      List<TransactionModel> txns =
          transactionRepository.getByBlockId(last!.id);
      pending = transactionRepository.getByBlockId(null);

      expect(txns.length, 1);
      expect(txns.elementAt(0).id, tx.id);
      expect(pending.length, 0);
    });

    test('Re-init - With Primary - Success ', () async {
      L0Storage l0storage = InMemL0Storage();
      KeyStorage keyStorage = InMemKeyStorage();
      Database database = sqlite3.openInMemory();
      NodeServiceBuilderStorage builder = NodeServiceBuilderStorage();
      builder.database = database;
      builder.keyStorage = keyStorage;
      await builder.loadPrimaryKey();
      builder.l0Storage = l0storage;
      builder.blockInterval = const Duration(seconds: 1);
      NodeService node = await builder.build();

      String address = node.address;
      expect(node.address, address);
    });

    test('Re-init - Invalid Address - Success ', () async {
      L0Storage l0storage = InMemL0Storage();
      KeyStorage keyStorage = InMemKeyStorage();
      Database database = sqlite3.openInMemory();
      NodeServiceBuilderStorage builder = NodeServiceBuilderStorage();
      builder.database = database;
      builder.keyStorage = keyStorage;
      await builder.loadPrimaryKey();
      builder.l0Storage = l0storage;
      builder.blockInterval = const Duration(seconds: 1);
      NodeService node = await builder.build();

      String address = const Uuid().v4();

      String address2 = node.address;

      expect(address != address2, true);
    });
  });
}
