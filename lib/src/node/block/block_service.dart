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

  List<int> serialize(BlockModel block) {
    List<int> head = header(block);
    List<int> txns = body(block);
    return [...head, ...txns];
  }

  Uint8List header(BlockModel block) {
    Uint8List serializedVersion = (BytesBuilder()
          ..add([encodeBigInt(BigInt.from(block.version)).length])
          ..add(encodeBigInt(BigInt.from(block.version))))
        .toBytes();
    Uint8List serializedTimestamp = (BytesBuilder()
          ..add([
            encodeBigInt(
                    BigInt.from(block.timestamp.millisecondsSinceEpoch ~/ 1000))
                .length
          ])
          ..add(encodeBigInt(
              BigInt.from(block.timestamp.millisecondsSinceEpoch ~/ 1000))))
        .toBytes();
    Uint8List serializedPreviousHash = block.previousHash;
    Uint8List serializedTransactionRoot = block.transactionRoot;
    return Uint8List.fromList([
      ...serializedVersion,
      ...serializedTimestamp,
      ...serializedPreviousHash,
      ...serializedTransactionRoot
    ]);
  }

  List<int> body(BlockModel block) {
    List<int> body = [];
    List<TransactionModel> txns = _transactionService.getByBlock(block.id!);
    for (TransactionModel txn in txns) {
      Uint8List serialized = txn.serialize();
      List<int> cSize = compactSize(serialized);
      body.addAll([...cSize, ...serialized]);
    }
    return body;
  }

  BlockModel fromSerialized(List<int> serialized, CryptoRSAPublicKey publicKey) {
    int pos = 0;
    int versionSize = serialized[0];
    pos++;
    int version = decodeBigInt(serialized.sublist(pos, versionSize)).toInt();
    pos += versionSize;
    int timestampSize = serialized[pos];
    pos++;
    int timestampInt =
        decodeBigInt(serialized.sublist(pos, pos + timestampSize)).toInt();
    pos += timestampSize;
    Uint8List previousHash =
        Uint8List.fromList(serialized.sublist(pos, pos + 32));
    pos += 32;
    Uint8List transactionRoot =
        Uint8List.fromList(serialized.sublist(pos, pos + 32));
    pos += 32;
    int length = 0;
    List<TransactionModel> txns = [];
    for (int i = pos; i < serialized.length; i += length) {
      int cSize0 = serialized[i];
      i++;
      if (cSize0 <= 252) {
        length = cSize0;
      } else {
        length = serialized[i];
        i++;
      }
      TransactionModel txn = TransactionModel.fromSerialized(
          Uint8List.fromList(serialized.sublist(i, i + length)));
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
        timestamp: DateTime.fromMillisecondsSinceEpoch(timestampInt * 1000),
        transactionRoot: transactionRoot,
        previousHash: previousHash,
        transactionCount: txns.length);
    block.id = Digest("SHA3-256").process(header(block));
    return block;
  }
}
