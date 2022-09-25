main() {
  //TODO FIX.

  /*group('xchain tests', () {
    Database db = sqlite3.openInMemory();
    InMemKeyStorage keyStorage = InMemKeyStorage();
    InMemL0Storage storage = InMemL0Storage();
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
      bytes.add(Bytes.encodeBigInt(BigInt.from(transactions.length)));
      transactions.forEach((txn) => bytes.add(txn.serialize()));
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
          await NodeService().init(db, InMemKeyStorage(), storage);
      BlockModel? block =
          await nodeService.getBlockById(blk.id!, xchainId: key.address);
      expect(block != null, true);
      expect(block!.id, blk.id);
      expect(block.version, blk.version);
      expect(Bytes.memEquals(block.previousHash, blk.previousHash), true);
      expect(Bytes.memEquals(block.transactionRoot, blk.transactionRoot), true);
      expect(block.timestamp.millisecondsSinceEpoch,
          blk.timestamp.millisecondsSinceEpoch);
    });
    test('create transaction, backup and retrieve by path', () async {
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
      TransactionModel originalTxn = transactions[Random().nextInt(49)];
      NodeService nodeService =
          await NodeService().init(db, InMemoryKey(), storage);

      TransactionModel? transaction =
          await nodeService.getTransactionByPath(originalTxn.path);
      expect(transaction != null, true);
      expect(Bytes.memEquals(transaction!.id!, originalTxn.id!), true);
      expect(transaction.version, originalTxn.version);
      expect(Bytes.memEquals(transaction.address, originalTxn.address), true);
      expect(Bytes.memEquals(transaction.contents, originalTxn.contents), true);
      expect(transaction.assetRef, originalTxn.assetRef);
      expect(
          Bytes.memEquals(transaction.merkelProof!, originalTxn.merkelProof!),
          true);
      expect(Bytes.memEquals(transaction.block!.id!, originalTxn.block!.id!),
          true);
      expect(transaction.timestamp, originalTxn.timestamp);
    });
  });*/
}
