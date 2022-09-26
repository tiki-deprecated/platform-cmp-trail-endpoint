/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

/// {@category Node}
library transaction;

import 'dart:typed_data';

import 'package:pointycastle/export.dart';
import 'package:sqlite3/sqlite3.dart';

import '../../utils/utils.dart';
import '../node_service.dart';

export 'transaction_model.dart';
export 'transaction_repository.dart';

/// The service to manage transactions in the chain.
class TransactionService {
  final TransactionRepository _repository;

  TransactionService(Database db) : _repository = TransactionRepository(db);

  /// Creates a [TransactionModel] with [contents].
  ///
  /// Uses the wallet address from [key] ([KeysModel.address]) to sign the transaction.
  /// If the [assetRef] is not set, it defaults to AA==.
  /// The return is a uncommitted [TransactionModel]. The [TransactionModel]
  /// should be added to a [BlockModel] by setting the [TransactionModel.block]
  /// and [TransactionModel.merkelProof] values followed by calling the [commit] method.
  TransactionModel create(Uint8List contents, KeyModel key,
      {String assetRef = 'AA=='}) {
    TransactionModel txn = TransactionModel(
        address: key.address, contents: contents, assetRef: assetRef);
    txn.signature =
        Rsa.sign(key.privateKey, txn.serialize(includeSignature: false));
    txn.id = Digest("SHA3-256").process(txn.serialize());
    _repository.save(txn);
    return txn;
  }

  /// Commits a [TransactionModel] by persisting its its [TransactionModel.block]
  /// and [TransactionModel.merkelProof] values.
  void commit(TransactionModel transaction) {
    if (transaction.block?.id == null || transaction.merkelProof == null) {
      throw StateError('set merkelProof and block before commit.');
    }
    _repository.commit(transaction);
  }

  /// Validates the [TransactionModel] inclusion in [TransactionModel.block] by
  /// checking validating its [TransactionModel.merkelProof] with [MerkelTree.validate].
  static bool validateInclusion(TransactionModel transaction, Uint8List root) =>
      MerkelTree.validate(transaction.id!, transaction.merkelProof!, root);

  /// Validates the [TransactionModel] integrity by rebuilds it hash [TransactionModel.id].
  static bool validateIntegrity(TransactionModel transaction) =>
      Bytes.memEquals(
          Digest("SHA3-256").process(transaction.serialize()), transaction.id!);

  /// Validates the author of the [TransactionModel] by calling [verify] with its
  /// [TransactionModel.signature].
  static bool validateAuthor(
          TransactionModel transaction, RsaPublicKey pubKey) =>
      Rsa.verify(pubKey, transaction.serialize(includeSignature: false),
          transaction.signature!);

  /// Gets all the transactions from a [BlockModel] by its [BlockModel.id].
  List<TransactionModel> getByBlock(Uint8List id) =>
      _repository.getByBlockId(id);

  /// Gets all the transactions that were not committed by [commit].
  List<TransactionModel> getPending() => _repository.getByBlockId(null);

  /// Creates a List of [TransactionModel]] from a [Uint8List] of the serialized
  /// block.
  ///
  /// This is the revert function for [serializeTransactions]. It should be used
  /// when recovering a block body.
  static List<TransactionModel> deserializeTransactions(
      Uint8List serializedBlock) {
    List<TransactionModel> txns = [];
    List<Uint8List> extractedBlockBytes =
        CompactSize.decode(serializedBlock);
    int transactionCount =
        Bytes.decodeBigInt(extractedBlockBytes[4]).toInt();
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
}
