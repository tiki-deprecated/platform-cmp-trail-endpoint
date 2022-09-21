/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/pointycastle.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';
import 'package:tiki_sdk_dart/node/node_service.dart';
import 'package:tiki_sdk_dart/utils/utils.dart';

import '../../in_mem_keys.dart';

void main() async {
  group('Cross chain reference tests', skip: apiId.isEmpty, () {
    test('Xchain repository test', () async {
      KeysService keysService = KeysService(InMemoryKeys());
      KeysModel keys = await keysService.create();
      Database db = sqlite3.openInMemory();
      XchainRepository xchainRepository = XchainRepository(db);
      XchainModel xchainModel = XchainModel(keys.privateKey.public);
      xchainRepository.save(xchainModel);
      XchainModel xchain = xchainRepository.get(base64.encode(keys.address))!;
      expect(xchain.address, xchainModel.address);
      expect(xchain.publicKey.encode(), xchainModel.publicKey.encode());
      expect(xchain.lastBlock, xchainModel.lastBlock);
    });
    test('Load block from backup', () async {
      List<BlockModel> blocks = [];
      Database db = sqlite3.openInMemory();
      InMemoryKeys inMemoryKeys = InMemoryKeys();
      NodeService nodeService = await NodeService().init(
          blkInterval: const Duration(seconds: 1),
          database: db,
          apiKey: apiId,
          keysInterface: inMemoryKeys);
      for (int i = 0; i < 10; i++) {
        int total = Random().nextInt(20);
        List<TransactionModel> transactions = [];
        for (int j = 0; j < total; j++) {
          TransactionModel txn = nodeService
              .write(Uint8List.fromList('test contents $j$i'.codeUnits));
          transactions.add(txn);
        }
        await Future.delayed(const Duration(seconds: 1));
      }
      BlockModel block = nodeService.getLastBlock()!;
      blocks.add(block);
      while (!UtilsBytes.memEquals(block.previousHash, Uint8List(1))) {
        block = (await nodeService
            .getBlockById(base64.encode(block.previousHash)))!;
        blocks.add(block);
      }
      db = sqlite3.openInMemory();
      inMemoryKeys = InMemoryKeys();
      nodeService = await NodeService().init(
          blkInterval: const Duration(seconds: 1),
          database: db,
          apiKey: apiId,
          keysInterface: inMemoryKeys);
      Uint8List xchainAddress = Digest("SHA3-256")
          .process(base64Url.decode(nodeService.publicKey.encode()));
      for (BlockModel blk in blocks) {
        BlockModel newBlock = (await nodeService.getBlockById(
            base64Url.encode(blk.id!),
            xchainAddress: base64Url.encode(xchainAddress)))!;
        expect(UtilsBytes.memEquals(newBlock.id!, blk.id!), true);
      }
      expect(1, 1);
    });
    test('Read remote blocks and transactions', () async {
      // create blocks
      // backup
      // get from backup
      // rebuild chain
      // compare blocks
    });
    test('Get transaction by asset reference', () async {
      // create multiple transactions
      // backup
      // get from backup
      // rebuild chain
      // get transactions from block
      // get transaction
    });
  });
}

String apiId = "d25d2e69-89de-47aa-b5e9-5e8987cf5318";
CryptoRSAPrivateKey privatekey = CryptoRSAPrivateKey.decode(
    'MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEBAoIBAQCExIiiGBl7MtWXnF1EpB3x/ygYKA5x7nyJz4Ot5utKqInlqz540js6VlBlu1K1W8yZfEshTPvoG5p3FvlONOYqA8h3+DcZKXIViMl1sduh60zkTRSbqT90PXvO/JmUQMQrpnPl0Wkr0+y3+pNw/7Hts5PGSIkCGpGI91yt0qkd7/y6stOsyC1EDJTIQMGNQI3Ty6l0ctSFuN1KvvGPDmhaVBqsUAK9RXoIBnFFYw/5G1PfN1aWRtOlVmp8gbz0hugCYvQ+0EkA0QYXbNBtrnqwpRwYisqfIRxeXgIzACeomGpm37/xjeWJdBVHglH6209Rw/b9Cqp3E/DV4Q6+AJoZAgMBAAECggEAX2lBa4N4JGIGvxp+qEpsvrEIJjv7DYM+embnkXymUJPH7YXfskIakDThOAqjSHO9F/wLndXOHiJgIf8fkEVRtpXbZeO57NotAy624F69oKIRMuv1yFubnzRkGf7Le5ADqf7HwTt5oiZ9MkXf2U/XlSP9KXyNATcIqW5iawQ9xqXbJS7TtFxcsQU7U2uv+w8kzQFgP6TZiAjHQ3yK9WTiQ2TEa8PZA9ouZNf52hn+D59mAJEtRYIiJOa4YdOk3xi9JKO1AeHC9LhbF8q63t5hWX4c5rFx65Znd1ydtvT/jxlyGONGbuGF4/+HtKA2zotGsyZGe9Yi6jEI+dt55GVsRQKBgQDLrEMDOE22AVNvmP1RI+gTvKzwKPsQtTNnfpwkW+RWHbSa4GJ8V9jcIgoARv8/IBY8vm1miEWBnlHan8KqIuIsgtJEph5+pENFI6fY0jdnsr9N8RthWgH68q+pq5/DCGFpbJuuAmBBcvRarc0l20j5Z6qOOiXoLwhDbojIZ5OXkwKBgQCm4McozdbQ9kybAiR8lq7l67XesQlnuE89DyyT6LmLpmvUWYjMm/25Vky4pS6NNDMM4HJfCO0V6j97ctxmcQL9W/qrxaSEhFtbHv6CnSNPgGBi9xsBCBE53D2k1JzGNHyjWmn+D5ispsuW8S17OpHbH0U0rUc/avVsUu6Fcgw7IwKBgQCEeJx1ga95y8767OUGW3ZdMADDi8QQj+rJS94+/825/UQ03/DusyyHsVQT7hmiczpDdBAv+j5LGjBfJD427s1w6f3dTLbU4/4lABXxvnju56HqDgIjBan4ENUUZF5bOh4xtcRkH4N/zkcEm7qs/r2uCjEypLt3EvAq+7/XqRakJQKBgAKrzGRJzytvFdDRWvYnj0sc179lxAnF+Ha4vHTtn7KtikJO4JKt2ITT7cxy0GjwMfT9zrbYtLrKEhQOxZpaKrsVctC3DCgW2kN+HoLGsx79pg1PeT4t++CaNt5hjNTbWDdhJhsr8ryous+CssCrMlR4jqoGMALC2oTOWwUFy05TAoGBAKrMw09XPdkevP2ouAWP5TjYWyF70fMUQQ5D8eqVJDKLABLK9DT+OGC6Zj57PpyiV0ldGW1dbsQ45/SMSZCS7Zo0V71Aznx8yOkWZQrInfhaZ/EDMUoppxrJVpt0VkyANf1o/EFNppJv754+tumPlbdVA9a8S3RDpW86fFRQSfsS');
KeysModel keys = KeysModel(
    Digest("SHA3-256").process(base64.decode(privatekey.public.encode())),
    privatekey);
