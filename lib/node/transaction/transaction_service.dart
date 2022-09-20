/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */
/// {@category Node}
library transaction;

import '../block/block_model.dart';
import '../node_service.dart';

import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';
import 'package:sqlite3/sqlite3.dart';
import '../../utils/utils.dart';
export 'transaction_model.dart';
export 'transaction_repository.dart';

/// The service to manage transactions in the chain.
class TransactionService {
  final TransactionRepository _repository;

  TransactionService(Database db) : _repository = TransactionRepository(db);

  /// Builds a [TransactionModel] with [contents].
  ///
  /// Uses the wallet address from [keys] ([KeysModel.address]) to sign the transaction.
  /// If the [assetRef] is not set, it defaults to AA==.
  /// The return is a uncommited [TransactionModel]. The [TransactionModel]
  /// should be added to a [BlockModel] by providing its [TransactionModel.block]
  /// and [TransactionModel.merkelProof] values and calling the [commit] method.
  TransactionModel build(
      {required Uint8List contents,
      required KeysModel keys,
      String assetRef = 'AA=='}) {
    TransactionModel txn = TransactionModel(
        address: keys.address, contents: contents, assetRef: assetRef);
    txn.signature = UtilsRsa.sign(keys.privateKey, txn.serialize());
    txn.id = Digest("SHA3-256").process(txn.serialize());
    txn = _repository.save(txn);
    return txn;
  }

  /// Commits a [TransactionModel] by persisting its its [TransactionModel.block]
  /// and [TransactionModel.merkelProof] values.
  void commit(TransactionModel transaction) => _repository.commit(transaction);

  /// Validates the [TransactionModel] inclusion in [TransactionModel.block] by
  /// checking validating its [TransactionModel.merkelProof] with [MerkelTree.validate].
  static bool validateInclusion(
          TransactionModel transaction, BlockModel block) =>
      MerkelTree.validate(
          transaction.id!, transaction.merkelProof!, block.transactionRoot);

  /// Validates the [TransactionModel] integrity by rebuilds it hash [TransactionModel.id].
  static bool validateIntegrity(TransactionModel transaction) =>
      UtilsBytes.memEquals(
          Digest("SHA3-256").process(transaction.serialize()), transaction.id!);

  /// Validates the author of the [TransactionModel] by calling [verify] with its
  /// [TransactionModel.signature].
  static bool validateAuthor(
          TransactionModel transaction, CryptoRSAPublicKey pubKey) =>
      UtilsRsa.verify(pubKey, transaction.serialize(includeSignature: false),
          transaction.signature!);

  /// Creates a [Uint8List] of the transactions included in a [BlockModel].
  ///
  /// This [Uint8List] is built as the body of the [BlockModel]. It creates a list
  /// of each [TransactionModel.serialize] bytes prepended by its size obtained
  /// by [UtilsCompactSize.toSize].
  Uint8List serializeTransactions(String blockId) {
    List<TransactionModel> txns = getByBlock(base64.decode(blockId));
    return staticTransactionsSerializer(txns);
  }

  static Uint8List staticTransactionsSerializer(List<TransactionModel> txns) {
    BytesBuilder body = BytesBuilder();
    for (TransactionModel txn in txns) {
      Uint8List serialized = txn.serialize();
      Uint8List cSize = UtilsCompactSize.toSize(serialized);
      body.add(cSize);
      body.add(serialized);
    }
    return body.toBytes();
  }

  /// Creates a List of [TransactionModel]] from a [Uint8List] of the serialized
  /// transactions.
  ///
  /// This is the revers function for [serializeTransactions]. It should be used
  /// when recovering a [BlockModel] body.
  static List<TransactionModel> deserializeTransactions(
      Uint8List serializedBlock) {
    List<TransactionModel> txns = [];
    List<Uint8List> extractedBlockBytes =
        UtilsCompactSize.decode(serializedBlock);
    int transactionCount =
        UtilsBytes.decodeBigInt(extractedBlockBytes[4]).toInt();
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

  /// Gets all the transactions from a [BlockModel] by its [BlockModel.id].
  List<TransactionModel> getByBlock(Uint8List blockId) =>
      _repository.getByBlockId(blockId);

  /// Gets all the transactions that were not commited by [commit].
  List<TransactionModel> getPending() => _repository.getPending();

  void addAll(List<TransactionModel> txns) {}
}
