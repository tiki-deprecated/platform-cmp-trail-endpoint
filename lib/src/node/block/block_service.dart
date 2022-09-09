import 'dart:typed_data';

import 'package:pointycastle/export.dart';
import 'package:sqlite3/sqlite3.dart';

import '../../utils/bytes.dart';
import '../../utils/merkel_tree.dart';
import '../../utils/page_model.dart';
import '../../utils/rsa/rsa_public_key.dart';
import '../transaction/transaction_model.dart';
import '../transaction/transaction_service.dart';
import 'block_model.dart';
import 'block_repository.dart';

class BlockService {
  static const int version = 1;
  final BlockRepository _repository;
  final TransactionService _transactionService;

  BlockService(Database db, this._transactionService)
      : _repository = BlockRepository(db);

  /// Create a new block from a list of transactions.
  ///
  /// Calculate the [MerkelTree] from [transactions] list.
  /// Calculate the [BlockModel.previousHash].
  /// Update the [transactions] with block id and merkel proof;
  /// Backup the new block with [BackupService].
  /// Return the [BlockModelResponse] with [BlockModel] and [MerkelTree].
  BlockModel create(List<TransactionModel> transactions) {
    List<Uint8List> hashes = transactions.map((e) => e.id!).toList();
    MerkelTree merkelTree = MerkelTree.build(hashes);
    Uint8List transactionRoot = merkelTree.root!;
    BlockModel? lastBlock = _repository.getLast();
    BlockModel block = BlockModel(
        previousHash: lastBlock == null
            ? Uint8List(1)
            : Digest("SHA3-256").process(header(lastBlock)),
        transactionRoot: transactionRoot,
        transactionCount: transactions.length);
    block.id = Digest("SHA3-256").process(header(block));
    for (TransactionModel transaction in transactions) {
      transaction.block = block;
      transaction.merkelProof = merkelTree.proofs[transaction.id];
      _transactionService.commit(transaction);
    }
    _repository.save(block);
    return block;
  }

  void prune(BlockModel blk) => _repository.prune(blk);

  void add(BlockModel blockModel) => _repository.save(blockModel);

  BlockModel? get(String id) => _repository.getById(id);

  // PageModel<BlockModel> getByChain(String xchainAddress) {
  //   return _repository.getByChain(xchainAddress);
  // }

  PageModel<BlockModel> getLocal() {
    return _repository.getLocal();
  }

  BlockModel? getLast(String xchainAddress) =>
      _repository.getLast(xchainIAddress: xchainAddress);

  Uint8List serialize(BlockModel block) {
    Uint8List head = header(block);
    Uint8List txns = body(block);
    return (BytesBuilder()
          ..add(head)
          ..add(txns))
        .toBytes();
  }

  Uint8List header(BlockModel block) {
    Uint8List serializedVersion = encodeBigInt(BigInt.from(block.version));
    Uint8List serializedTimestamp = (BytesBuilder()
          ..add(encodeBigInt(
              BigInt.from(block.timestamp.millisecondsSinceEpoch ~/ 1000))))
        .toBytes();
    Uint8List serializedPreviousHash = block.previousHash;
    Uint8List serializedTransactionRoot = block.transactionRoot;
    return (BytesBuilder()
          ..add(compactSize(serializedVersion))
          ..add(serializedVersion)
          ..add(compactSize(serializedTimestamp))
          ..add(serializedTimestamp)
          ..add(compactSize(serializedPreviousHash))
          ..add(serializedPreviousHash)
          ..add(compactSize(serializedTransactionRoot))
          ..add(serializedTransactionRoot))
        .toBytes();
  }

  Uint8List body(BlockModel block) {
    BytesBuilder body = BytesBuilder();
    List<TransactionModel> txns = _transactionService.getByBlock(block.id!);
    for (TransactionModel txn in txns) {
      Uint8List serialized = txn.serialize();
      Uint8List cSize = compactSize(serialized);
      body.add(cSize);
      body.add(serialized);
    }
    return body.toBytes();
  }

  BlockModel fromSerialized(Uint8List serialized, CryptoRSAPublicKey publicKey,
      {persistBlock = false, persistTransactions = false}) {
    List<Uint8List> extractedBlockBytes = extractSerializeBytes(serialized);
    int version = decodeBigInt(extractedBlockBytes[0]).toInt();
    DateTime timestamp = DateTime.fromMillisecondsSinceEpoch(
        decodeBigInt(extractedBlockBytes[1]).toInt() * 1000);
    Uint8List previousHash = extractedBlockBytes[2];
    Uint8List transactionRoot = extractedBlockBytes[3];
    List<TransactionModel> txns = [];
    for (int i = 4; i < extractedBlockBytes.length; i++) {
      TransactionModel txn =
          TransactionModel.fromSerialized(extractedBlockBytes[i]);
      txn.id = Digest("SHA3-256").process(txn.serialize());
      if (!TransactionService.validateAuthor(txn, publicKey)) {
        throw Exception('Invalid signature for $txn');
      }
      txns.add(txn);
    }
    MerkelTree merkelTree =
        MerkelTree.build(txns.map((TransactionModel txn) => txn.id!).toList());
    if (!memEquals(merkelTree.root!, transactionRoot)) {
      throw Exception('Invalid transaction root');
    }
    for (int i = 0; i < txns.length; i++) {
      TransactionModel txn = txns[i];
      if (!MerkelTree.validate(
          txn.id!, merkelTree.proofs[i]!, transactionRoot)) {
        throw Exception('Transaction inclusion could not be validated: $txn');
      }
    }
    BlockModel block = BlockModel(
        version: version,
        timestamp: timestamp,
        transactionRoot: transactionRoot,
        previousHash: previousHash,
        transactionCount: txns.length);
    block.id = Digest("SHA3-256").process(header(block));
    if (persistBlock) {
      add(block);
    }
    if (persistTransactions) {
      _transactionService.addAll(txns);
    }
    return block;
  }
}
