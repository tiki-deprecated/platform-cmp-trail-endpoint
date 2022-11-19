import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/api.dart';
import 'package:test/test.dart';
import 'package:tiki_sdk_dart/node/node_service.dart';
import 'package:tiki_sdk_dart/utils/utils.dart';
import 'package:uuid/uuid.dart';

import '../in_mem_node_service_builder.dart';

void main() {
  group('Node tests', () {
    test('Init - No Primary - Success ', () async {
      InMemNodeServiceBuilder inMemNodeServiceBuilder =
          InMemNodeServiceBuilder();
      NodeService node = await inMemNodeServiceBuilder.build();
      Uint8List address = Bytes.base64UrlDecode(node.address);
      Uint8List? publicKey = await inMemNodeServiceBuilder.l0Storage
          .read('${Bytes.base64UrlEncode(address)}/public.key');

      expect(publicKey != null, true);
      expect(Digest("SHA3-256").process(publicKey!), address);

      KeyService keyService = KeyService(inMemNodeServiceBuilder.keyStorage);
      KeyModel? key = await keyService.get(node.address);
      RsaPublicKey rsaPublicKey = RsaPublicKey.decode(base64.encode(publicKey));

      expect(key != null, true);
      expect(rsaPublicKey, key?.privateKey.public);

      await Future.delayed(const Duration(seconds: 3));

      BlockRepository blockRepository =
          BlockRepository(inMemNodeServiceBuilder.database);
      TransactionRepository transactionRepository =
          TransactionRepository(inMemNodeServiceBuilder.database);

      BlockModel? last = blockRepository.getLast();
      List<TransactionModel> pending = transactionRepository.getByBlockId(null);

      expect(last == null, true);
      expect(pending.isEmpty, true);
    });

    test('Write - Success ', () async {
      InMemNodeServiceBuilder inMemNodeServiceBuilder =
          InMemNodeServiceBuilder();
      inMemNodeServiceBuilder.blockInterval = const Duration(seconds: 1);
      NodeService node = await inMemNodeServiceBuilder.build();
      TransactionModel tx =
          await node.write(Uint8List.fromList(utf8.encode(const Uuid().v4())));

      expect(tx.id != null, true);
      expect(tx.signature != null, true);

      TransactionRepository transactionRepository =
          TransactionRepository(inMemNodeServiceBuilder.database);
      List<TransactionModel> pending = transactionRepository.getByBlockId(null);
      expect(pending.length, 1);

      await Future.delayed(const Duration(seconds: 3));

      BlockRepository blockRepository =
          BlockRepository(inMemNodeServiceBuilder.database);
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
      InMemNodeServiceBuilder inMemNodeServiceBuilder =
          InMemNodeServiceBuilder();
      inMemNodeServiceBuilder.blockInterval = const Duration(seconds: 1);
      NodeService node = await inMemNodeServiceBuilder.build();

      String address = node.address;
      expect(node.address, address);
    });

    test('Re-init - Invalid Address - Success ', () async {
      InMemNodeServiceBuilder inMemNodeServiceBuilder =
          InMemNodeServiceBuilder();
      inMemNodeServiceBuilder.blockInterval = const Duration(seconds: 1);
      NodeService node = await inMemNodeServiceBuilder.build();

      String address = const Uuid().v4();

      String address2 = node.address;

      expect(address != address2, true);
    });
  });
}
