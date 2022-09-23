import 'dart:typed_data';

import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';
import 'package:tiki_sdk_dart/node/node_service.dart';
import 'package:tiki_sdk_dart/utils/utils.dart';

import '../../in_mem_backup.dart';
import '../../in_mem_key.dart';

main() {
  group('xchain tests', () {
    Database db = sqlite3.openInMemory();
    InMemoryKey keyStorage = InMemoryKey();
    InMemBackup storage = InMemBackup();
    KeyService keysService = KeyService(keyStorage);
    TransactionService transactionService = TransactionService(db);
    BlockService blockService = BlockService(db);

    Uint8List? getBlock(id) {
      BlockModel? header = blockService.get(id);
      if (header == null) return null;

      List<TransactionModel> transactions = transactionService.getByBlock(id);
      if (transactions.isEmpty) return null;

      BytesBuilder bytes = BytesBuilder();
      bytes.add(header.serialize());
      bytes.add(TransactionService.serializeTransactions(transactions));
      return bytes.toBytes();
    }

    test('create block, backup and retrieve', () async {
      KeyModel key = await keysService.create();
      BackupService backupService = BackupService(storage, db, key, getBlock);
      List<TransactionModel> transactions = [];
      for (int i = 0; i < 50; i++) {
        TransactionModel txn =
            transactionService.create(Uint8List.fromList([i]), key);
        transactions.add(txn);
      }
      MerkelTree merkelTree =
          MerkelTree.build(transactions.map((txn) => txn.id!).toList());
      Uint8List transactionRoot = merkelTree.root!;
      BlockModel blk = blockService.create(transactionRoot);
      for (TransactionModel transaction in transactions) {
        transaction.block = blk;
        transaction.merkelProof = merkelTree.proofs[transaction.id];
        transactionService.commit(transaction);
      }
      blockService.commit(blk);
      backupService.block(blk.id!);

      db = sqlite3.openInMemory();
      NodeService nodeService =
          await NodeService().init(db, InMemoryKey(), storage);
      BlockModel? block =
          await nodeService.getBlockById(blk.id!, xchainId: key.address);
      expect(block != null, true);
      expect(block!.id, blk.id);
      expect(block.version, blk.version);
      expect(UtilsBytes.memEquals(block.previousHash, blk.previousHash), true);
      expect(UtilsBytes.memEquals(block.transactionRoot, blk.transactionRoot),
          true);
      expect(block.timestamp.millisecondsSinceEpoch,
          blk.timestamp.millisecondsSinceEpoch);
    });
  });
}
