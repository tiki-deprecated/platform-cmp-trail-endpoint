import 'dart:convert';
import 'dart:typed_data';

import 'package:sqlite3/sqlite3.dart';

import '../../utils/merkel_tree.dart';
import '../../utils/rsa/rsa.dart';
import '../../utils/rsa/rsa_public_key.dart';
import '../../utils/utils.dart';
import '../block/block_model.dart';
import '../keys/keys_model.dart';
import 'transaction_model.dart';
import 'transaction_repository.dart';

class TransactionService {
  final TransactionRepository _repository;

  TransactionService(Database? db)
      : _repository = TransactionRepository(db: db);

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
        address: keys.address,
        contents: contents,
        assetRef: Uint8List.fromList(assetRef.codeUnits));
    txn.signature = sign(keys.privateKey, txn.serialize());
    txn.id = sha256(txn.serialize());
    txn = _repository.save(txn);
    return txn;
  }

  Future<void> update(TransactionModel transaction, KeysModel key) async {
    if (!memEquals(key.address, transaction.address)) {
      throw Exception(
          'Check the address. Invalid key found for: ${base64Url.encode(transaction.address)}.');
    }
    _repository.update(transaction);
  }

  /// Validates the transaction hash and merkel proof (if present).
  static bool checkInclusion(TransactionModel transaction, BlockModel block) =>
      MerkelTree.validate(
          transaction.id!, transaction.merkelProof!, block.transactionRoot);

  static bool checkIntegrity(TransactionModel transaction) =>
      memEquals(sha256(transaction.serialize()), transaction.id!);

  /// Validates the transaction signature.
  static bool checkAuthor(
          TransactionModel transaction, CryptoRSAPublicKey pubKey) =>
      verify(pubKey, transaction.serialize(), transaction.signature!);

  /// Gets all [TransactionModel] that belongs to the [BlockModel] with [blockId].
  List<TransactionModel> getByBlock(Uint8List blockId) =>
      _repository.getByBlock(blockId);

  /// Gets the [TransactionModel] by its id.
  TransactionModel? getById(String id) => _repository.getById(id);

  /// Gets the [TransactionModel]s that were not added to a block yet;
  List<TransactionModel> getNoBlock() => _repository.getBlockNull();

  /// Removes the [TransactionModel] from local database.
  Future<void> discard(Uint8List id) async => _repository.remove(id);
}
