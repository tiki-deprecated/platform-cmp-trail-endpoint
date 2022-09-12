import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';
import 'package:sqlite3/sqlite3.dart';

import '../../utils/merkel_tree.dart';
import '../../utils/rsa/rsa.dart';
import '../../utils/rsa/rsa_public_key.dart';
import '../../utils/bytes.dart';
import '../../utils/compact_size.dart' as compactSize;
import '../block/block_model.dart';
import '../keys/keys_model.dart';
import 'transaction_model.dart';
import 'transaction_repository.dart';

class TransactionService {
  final TransactionRepository _repository;

  TransactionService(Database db) : _repository = TransactionRepository(db);

  /// Creates a [TransactionModel] with [contents].
  ///
  /// Uses the wallet [address] to sign the transaction.
  /// If the [assetRef] defaults to 0x00 unless this txn refers to anohtes txn
  /// address/block_header_sha3_hash/transaction_sha3_hash
  /// sha3 of block header - txn base64 or hex? websafe base64?
  /// If the wallet does not have the private key for [address], throws an error.
  TransactionModel create(
      {required Uint8List contents,
      required KeysModel keys,
      String assetRef = '0x00'}) {
    TransactionModel txn = TransactionModel(
        address: keys.address, contents: contents, assetRef: assetRef);
    txn.signature = sign(keys.privateKey, txn.serialize());
    txn.id = Digest("SHA3-256").process(txn.serialize());
    txn = _repository.save(txn);
    return txn;
  }

  void commit(TransactionModel transaction) => _repository.commit(transaction);

  static bool validateInclusion(
          TransactionModel transaction, BlockModel block) =>
      MerkelTree.validate(
          transaction.id!, transaction.merkelProof!, block.transactionRoot);

  static bool validateIntegrity(TransactionModel transaction) => memEquals(
      Digest("SHA3-256").process(transaction.serialize()), transaction.id!);

  static bool validateAuthor(
          TransactionModel transaction, CryptoRSAPublicKey pubKey) =>
      verify(pubKey, transaction.serialize(includeSignature: false),
          transaction.signature!);

  Uint8List serializeTransactions(String blockId) {
    BytesBuilder body = BytesBuilder();
    List<TransactionModel> txns = getByBlock(base64.decode(blockId));
    for (TransactionModel txn in txns) {
      Uint8List serialized = txn.serialize();
      Uint8List cSize = compactSize.toSize(serialized);
      body.add(cSize);
      body.add(serialized);
    }
    return body.toBytes();
  }

  static List<TransactionModel> transactionsFromSerializedBlock(
      Uint8List serializedBlock) {
    List<TransactionModel> txns = [];
    List<Uint8List> extractedBlockBytes = compactSize.decode(serializedBlock);
    int transactionCount = decodeBigInt(extractedBlockBytes[4]).toInt();
    if (extractedBlockBytes.sublist(5).length == transactionCount) {
      throw Exception(
          'Invalid transaction count. Expected $transactionCount. Got ${extractedBlockBytes.sublist(5).length}');
    }
    for (int i = 5; i < extractedBlockBytes.length; i++) {
      TransactionModel txn =
          TransactionModel.deserialize(extractedBlockBytes[i]);
      if (validateIntegrity(txn)) throw Exception('Corrupted transaction $txn');
      txns.add(txn);
    }
    return txns;
  }

  List<TransactionModel> getByBlock(Uint8List blockId) =>
      _repository.getByBlockId(blockId);

  TransactionModel? getById(String id) => _repository.getById(id);

  List<TransactionModel> getPending() => _repository.getPending();

  void prune(Uint8List id) async => _repository.prune(id);

  void addAll(List<TransactionModel> txns) => _repository.addAll(txns);
}
