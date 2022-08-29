import 'dart:convert';
import 'dart:typed_data';

import 'package:sqlite3/sqlite3.dart';

import '../../utils/merkel_tree.dart';
import '../../utils/rsa/rsa.dart';
import '../../utils/utils.dart';
import '../keys/keys_model.dart';
import '../keys/keys_service.dart';
import 'transaction_model.dart';
import 'transaction_repository.dart';

class TransactionService {
  final TransactionRepository _repository;
  final KeysService _keysService;

  TransactionService(this._keysService, Database? db)
      : _repository = TransactionRepository(db: db);

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
    KeysModel? key = await _keysService.get(address);
    if (key == null) {
      throw Exception('Check the address. No private key found for: $address.');
    }
    TransactionModel txn = TransactionModel(
        address: Uint8List.fromList(address.codeUnits),
        contents: contents,
        assetRef: Uint8List.fromList(assetRef.codeUnits));
    txn.signature = sign(key.privateKey, txn.serialize());
    txn.id = sha256(txn.serialize());
    txn = _repository.save(txn);
    return txn;
  }

  Future<void> update(TransactionModel transaction) async {
    KeysModel? key =
        await _keysService.get(base64Url.encode(transaction.address));
    if (key == null) {
      throw Exception(
          'Check the address. No private key found for: ${base64Url.encode(transaction.address)}.');
    }
    _repository.update(transaction);
  }

  /// Validates the transaction hash and merkel proof (if present).
  Future<bool> validateIntegrity(TransactionModel transaction,
      {Uint8List? merkelRoot}) async {
    Uint8List hash = sha256(transaction.serialize());
    if (!memEquals(hash, transaction.id!)) return false;
    if (merkelRoot != null) {
      return MerkelTree.validate(
          transaction.id!, transaction.merkelProof!, merkelRoot);
    }
    return true;
  }

  /// Validates the transaction signature.
  Future<bool> validateAuthor(TransactionModel transaction) async {
    // verify signature
    return true;
  }

  /// Gets all [TransactionModel] that belongs to the [BlockModel] with [blockId].
  List<TransactionModel> getByBlock(String blockId) =>
      _repository.getByBlock(blockId);

  /// Gets the [TransactionModel] by its id.
  TransactionModel? getById(String id) => _repository.getById(id);

  /// Removes the [TransactionModel] from local database.
  Future<void> discard(String id) async => _repository.remove(id);
}
