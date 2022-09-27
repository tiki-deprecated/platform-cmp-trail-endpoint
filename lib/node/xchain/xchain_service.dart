/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */
/// {@category Node}
/// Handles cross chain references.
library xchain;

import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/api.dart';
import 'package:sqlite3/sqlite3.dart';

import '../../utils/utils.dart';
import '../l0_storage.dart';
import '../node_service.dart';
import 'xchain_model.dart';
import 'xchain_repository.dart';

export 'xchain_model.dart';
export 'xchain_repository.dart';

/// The service to handle [XchainModel] references and updates.
class XchainService {
  final XchainRepository _repository;
  final L0Storage _l0storage;

  XchainService(Database db, this._l0storage)
      : _repository = XchainRepository(db);

  /// Updates the [XchainModel.lastBlock].
  void update(Uint8List address, Uint8List lastBlock) =>
      _repository.update(address, lastBlock);

  /// Gets a xchain from local database.
  XchainModel? get(Uint8List address) => _repository.get(address);

  /// Adds a new Xchain by its [address].
  /// 
  /// The service gets the [XchainModel.publicKey] from [L0Storage] and saves
  /// it with [BackupRepository].
  Future<XchainModel> loadKey(Uint8List address) async {
    XchainModel? xchain = _repository.get(address);
    if (xchain == null) {
      Uint8List? bytesPublicKey =
          await _l0storage.read('${base64Url.encode(address)}/public.key');
      RsaPublicKey publicKey =
          RsaPublicKey.decode(base64Encode(bytesPublicKey!));
      xchain = XchainModel(publicKey);
      _repository.save(xchain);
    }
    return xchain;
  }

  Future<Map<BlockModel, List<TransactionModel>>> loadXchain(
      XchainModel xchain, {List<String> skip = const []}) async {
    Map<String, Uint8List> serializedblocks =
        await _l0storage.getAll(base64Url.encode(xchain.address));
    Map<BlockModel, List<TransactionModel>> blocks = {};
    for (String blockId in serializedblocks.keys) {
      if (blockId == 'public.key' || skip.contains(blockId.replaceAll('.block', ''))) continue;
      Uint8List serializedBackup = serializedblocks[blockId]!;
      List<Uint8List> backupList = CompactSize.decode(serializedBackup);
      Uint8List signature = backupList[0];
      Uint8List serializedBlock = backupList[1];
      if (!Rsa.verify(xchain.publicKey, serializedBlock, signature)) {
        throw StateError('Backup signature could not be verified for $blockId');
      }
      BlockModel block = BlockModel.deserialize(serializedBlock);
      if (!Bytes.memEquals(Digest('SHA3-256').process(block.serialize()),
          base64Url.decode(blockId.replaceAll('.block', '')))) {
        throw Exception('Corrupted Block ${block.toString()}');
      }
      List<TransactionModel> transactions =
          TransactionService.deserializeTransactions(serializedBlock);
      MerkelTree merkelTree = MerkelTree.build(
          transactions.map((TransactionModel txn) => txn.id!).toList());
      if (!Bytes.memEquals(block.transactionRoot, merkelTree.root!)) {
        throw Exception('Invalid transaction root for ${block.toString()}');
      }
      for (TransactionModel transaction in transactions) {
        transaction.block = block;
        transaction.merkelProof = merkelTree.proofs[transaction.id!];
        if (!TransactionService.validateAuthor(transaction, xchain.publicKey)) {
          throw Exception(
              'Transaction authorshhip could not be verified: ${transaction.toString()}');
        }
      }
      block.transactionRoot = merkelTree.root!;
      blocks[block] = transactions;
    }
    return blocks;
  }
}
