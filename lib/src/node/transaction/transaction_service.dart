import 'dart:typed_data';

import 'transaction_model.dart';
import 'transaction_repository.dart';

class TransactionService {
  final TransactionRepository _repository;

  TransactionService({database})
      : _repository = TransactionRepository(database);

  /// Creates a [TransactionModel] with [contents].
  ///
  /// Uses the wallet [address] to sign the transaction.
  /// If the [assetRef] is null, that means it is a mint transaction and
  /// [TransactionModel.assetRef] should be `0x00`.
  /// If the wallet does not have the private key for [address], throws and error.
  Future<TransactionModel> createTransaction(String address,
      {Uint8List? contents, String? assetRef}) {
    throw UnimplementedError();
  }

  /// Validates the transaction.
  Future<bool> validateTransaction(
    TransactionModel transaction, {
    checkSignature = true,
    checkInBlock = false,
    checkMerkelProof = false,
  }) async {
    throw UnimplementedError();
  }

  /// Serializes the transaction to be included in the block body.
  String serialize(TransactionModel transaction) {
    throw UnimplementedError();
  }
}
