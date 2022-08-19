import 'dart:typed_data';

import '../keystore/keystore_model.dart';
import '../keystore/keystore_service.dart';
import 'transaction_model.dart';
import 'transaction_repository.dart';

class TransactionService {
  final TransactionRepository _repository;
  final KeystoreService _keystore = KeystoreService();

  TransactionService({database})
      : _repository = TransactionRepository(database);

  /// Creates a [TransactionModel] with [contents].
  ///
  /// Uses the wallet [address] to sign the transaction.
  /// If the [assetRef] defaults to 0x00 unless this txn refers to anohtes txn
  /// address/block_header_sha3_hash/transaction_sha3_hash
  /// sha3 of block header - txn base64 or hex? websafe base64?
  /// If the wallet does not have the private key for [address], throws an error.
  Future<TransactionModel> create(
      {required String address,
      required Uint8List contents,
      String assetRef = '0x00'}) async {
    KeystoreModel? key = await _keystore.get(address);
    if (key == null) {
      throw Exception(
          'Check the address. No private key found for: $address.');
    }
    TransactionModel txn = TransactionModel(
        address: address, contents: contents, assetRef: assetRef);
    txn.signature = await _sign(txn, key);
    txn.id = await _hash(txn, key);
    txn = _repository.save(txn);
    return txn;
  }

  /// Validates the transaction hash and merkel proof (if present).
  Future<bool> validateIntegrity(TransactionModel transaction) async {
    KeystoreModel? txnKey = await _keystore.get(transaction.address);
    // check hash with public key
    // check merkel proof with private key?
    return true;
  }

  /// Validates the transaction signature.
  Future<bool> validateAuthor(TransactionModel transaction) async {
    KeystoreModel? txnKey = await _keystore.get(transaction.address);
    // verify signature with public key
    return true;
  }

  /// Gets all [TransactionModel] that belongs to the [BlockModel] with [blockId].
  List<TransactionModel> getByBlock(String blockId) =>
      _repository.getByBlock(blockId);

  /// Gets the [TransactionModel] by its id.
  TransactionModel? getById(String id) => _repository.getById(id);

  /// Removes the [TransactionModel] from local database.
  Future<void> discard(String id) async => _repository.remove(id);

  /// Serializes the transaction to be included in the block body.
  Uint8List serialize(TransactionModel transaction) {
    throw UnimplementedError();
  }

  Future<String> _sign(TransactionModel txn, KeystoreModel key) async {
    // sign with private key
    // signature should be null
    return '';
  }

  Future<String> _hash(TransactionModel txn, KeystoreModel key) async {
    // hash with public key
    // should include signature
    return '';
  }
}
