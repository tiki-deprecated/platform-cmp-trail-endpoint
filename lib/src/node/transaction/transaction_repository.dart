import 'dart:convert';
import 'dart:typed_data';

import 'package:sqlite3/sqlite3.dart';
import '../../utils/utils.dart';
import '../block/block_model.dart';
import '../block/block_repository.dart';
import '../xchain/xchain_model.dart';
import '../xchain/xchain_repository.dart';
import 'transaction_model.dart';

class TransactionRepository {
  static const table = 'transactions';

  final Database _db;

  TransactionRepository({Database? db}) : _db = db ?? sqlite3.openInMemory() {
    createTable();
  }

  Future<void> createTable() async {
    _db.execute('''
      CREATE TABLE IF NOT EXISTS $table (
          seq INTEGER PRIMARY KEY,
          id STRING,
          merkel_proof BLOB,
          version INTEGER NOT NULL,
          address BLOB NOT NULL,
          contents BLOB NOT NULL,
          asset_ref TEXT NOT NULL,
          block_id INTEGER, 
          timestamp INTEGER NOT NULL,
          signature TEXT NOT NULL
      );
    ''');
  }

  TransactionModel save(TransactionModel transaction) {
    _db.execute('''INSERT INTO $table VALUES (
        ${transaction.seq}, 
        ${uint8ListToBase64Url(transaction.id, nullable: false, addQuotes: true)}, 
        ${uint8ListToBase64Url(transaction.merkelProof, addQuotes: true, nullable: true)},
        ${transaction.version}, 
        ${uint8ListToBase64Url(transaction.address, addQuotes: true)}, 
        ${uint8ListToBase64Url(transaction.contents, addQuotes: true)}, 
        ${uint8ListToBase64Url(transaction.assetRef, addQuotes: true)}, 
        ${transaction.block?.id}, 
        ${transaction.timestamp.millisecondsSinceEpoch ~/ 1000}, 
        ${uint8ListToBase64Url(transaction.signature, nullable: true, addQuotes: true)});''');
    transaction.seq = _db.lastInsertRowId;
    return transaction;
  }

  TransactionModel update(TransactionModel transaction) {
    _db.execute('''UPDATE $table SET
        merkel_proof = ${uint8ListToBase64Url(transaction.merkelProof, addQuotes: true, nullable: true)}, 
        block_id = ${uint8ListToBase64Url(transaction.block!.id, addQuotes: true, nullable: true)}
        WHERE id = ${uint8ListToBase64Url(transaction.id!, addQuotes: true, nullable: true)};  
        ''');
    return getById(base64Url.encode(transaction.id!))!;
  }

  List<TransactionModel> getByBlock(Uint8List? blockId) {
    String blockIdBase64 = uint8ListToBase64Url(blockId)!;
    String whereStmt = 'WHERE block_id = "$blockIdBase64"';
    return _select(whereStmt: whereStmt);
  }

  List<TransactionModel> getBlockNull() {
    String whereStmt = 'WHERE block_id IS NULL';
    return _select(whereStmt: whereStmt);
  }

  TransactionModel? getById(String id) {
    List<TransactionModel> transactions =
        _select(whereStmt: "WHERE transactions.id = '$id'");
    return transactions.isNotEmpty ? transactions[0] : null;
  }

  Future<void> remove(Uint8List id) async {
    _db.execute(
        'DELETE FROM $table WHERE id = "${uint8ListToBase64Url(id, nullable: false, addQuotes: true)}"');
  }

  List<TransactionModel> _select({int? page, String? whereStmt}) {
    ResultSet results = _db.select('''
        SELECT 
          $table.id as 'txn.id',
          $table.seq as 'txn.seq',
          $table.version as 'txn.version',
          $table.address as 'txn.address',
          $table.contents as 'txn.contents',
          $table.asset_ref as 'txn.asset_ref',
          $table.merkel_proof as 'txn.merkel_proof',
          $table.block_id as 'txn.block_id',
          $table.timestamp as 'txn.timestamp',
          $table.signature as 'txn.signature',
          ${BlockRepository.table}.id as 'blocks.id',
          ${BlockRepository.table}.version as 'blocks.version',
          ${BlockRepository.table}.previous_hash as 'blocks.previous_hash',
          ${BlockRepository.table}.xchain_uri as 'blocks.xchain_uri',
          ${BlockRepository.table}.transaction_root as 'blocks.transaction_root',
          ${BlockRepository.table}.transaction_count as 'blocks.transaction_count',
          ${BlockRepository.table}.timestamp as 'blocks.timestamp',
          ${XchainRepository.table}.id as 'xchains.id',
          ${XchainRepository.table}.pubkey as 'xchains.pubkey',
          ${XchainRepository.table}.last_checked as 'xchains.last_checked',
          ${XchainRepository.table}.uri as 'xchains.uri'
        FROM $table
        LEFT JOIN ${BlockRepository.table} as blocks
        ON transactions.block_id = blocks.id
        LEFT JOIN ${XchainRepository.table} as xchains
        ON blocks.xchain_uri = xchains.id 
        ${whereStmt ?? ''}
        ${page == null ? '' : 'LIMIT ${page * 100},100'};
        ''');
    List<TransactionModel> transactions = [];
    for (final Row row in results) {
      Map<String, dynamic>? blockMap = row['blocks.id'] == null
          ? null
          : {
              'id': base64UrlToUint8List((row['blocks.id'])),
              'version': row['blocks.version'],
              'previous_hash':
                  base64UrlToUint8List(row['blocks.previous_hash']),
              'transaction_root':
                  base64UrlToUint8List(row['blocks.transaction_root']),
              'transaction_count': row['blocks.transaction_count'],
              'timestamp': row['blocks.timestamp'],
              'xchain': row['xchains.id'] == null
                  ? null
                  : XchainModel.fromMap({
                      'id': row['xchains.id'],
                      'last_checked': row['xchains.last_checked'],
                      'uri': row['xchains.uri'],
                    })
            };
      Map<String, dynamic>? transactionMap = {
        'id': base64UrlToUint8List(row['txn.id']),
        'seq': row['txn.seq'],
        'version': row['txn.version'],
        'address': base64UrlToUint8List(row['txn.address']),
        'contents': base64UrlToUint8List(row['txn.contents']),
        'asset_ref': base64UrlToUint8List(row['txn.asset_ref']),
        'merkel_proof': base64UrlToUint8List(row['txn.merkel_proof']),
        'timestamp':
            DateTime.fromMillisecondsSinceEpoch(row['txn.timestamp'] * 1000),
        'signature': base64UrlToUint8List(row['txn.signature']),
        'block': blockMap == null ? null : BlockModel.fromMap(blockMap)
      };
      TransactionModel transaction = TransactionModel.fromMap(transactionMap);
      transactions.add(transaction);
    }
    return transactions;
  }
}
