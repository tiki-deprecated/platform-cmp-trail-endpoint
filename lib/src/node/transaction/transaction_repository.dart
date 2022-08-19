import 'package:sqlite3/sqlite3.dart';
import '../block/block_model.dart';
import '../block/block_repository.dart';
import '../xchain/xchain_model.dart';
import '../xchain/xchain_repository.dart';
import 'transaction_model.dart';

class TransactionRepository {
  static const table = 'transactions';

  final Database _db;

  TransactionRepository(this._db);

  Future<void> createTable() async {
    _db.execute('''
      CREATE TABLE IF NOT EXISTS $table (
          seq INTEGER PRIMARY KEY,
          id STRING,
          version INTEGER NOT NULL,
          address TEXT NOT NULL,
          contents BLOB NOT NULL,
          asset_ref TEXT NOT NULL,
          merkel_proof BLOB,
          block_id INTEGER, 
          timestamp INTEGER NOT NULL;
          signature TEXT NOT NULL;
      );
    ''');
  }

  TransactionModel save(TransactionModel transaction) {
    _db.execute('''INSERT INTO $table VALUES 
        ('${transaction.id}', '${transaction.version}', '${transaction.address}', 
        '${transaction.contents}', '${transaction.assetRef}', '${transaction.merkelProof}', 
        '${transaction.block?.id}', '${transaction.timestamp.millisecondsSinceEpoch ~/ 1000}', 
        '${transaction.signature}');''');
    return getById(transaction.id!)!;
  }

  List<TransactionModel> getByBlock(String blockId) {
    String whereStmt = 'WHERE block_id = $blockId';
    return _select(whereStmt: whereStmt);
  }

  TransactionModel? getById(String id) {
    List<TransactionModel> transactions =
        _select(whereStmt: 'WHERE block_id = $id');
    return transactions.isNotEmpty ? transactions[0] : null;
  }

  Future<void> remove(String id) async {
    _db.execute('DELETE FROM $table WHERE id = $id;');
  }

  List<TransactionModel> _select({int? page, String? whereStmt}) {
    ResultSet results = _db.select('''
        SELECT 
          $table.id as 'txn.id',
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
          ${BlockRepository.table}.xchain_id as 'blocks.xchain_id',
          ${BlockRepository.table}.transaction_root as 'blocks.transaction_root',
          ${BlockRepository.table}.transaction_count as 'blocks.transaction_count',
          ${BlockRepository.table}.timestamp as 'blocks.timestamp',
          ${XchainRepository.table}.id as 'xchains.id',
          ${XchainRepository.table}.last_checked as 'xchains.last_checked',
          ${XchainRepository.table}.uri as 'xchains.uri'
        FROM $table as txns
        LEFT JOIN ${BlockRepository.table} as blocks
        ON txn.block_id = blocks.id
        LEFT JOIN ${XchainRepository.table} as xchains
        ON blocks.xchain_id = xchains.id 
        ${whereStmt ?? ''}
        ${page == null ? '' : 'LIMIT ${page * 100},100'};
        ''');
    List<TransactionModel> transactions = [];
    for (final Row row in results) {
      Map<String, dynamic>? blockMap = row['blocks.id'] == null
          ? null
          : {
              'id': row['blocks.id'],
              'version': row['blocks.version'],
              'previous_hash': row['blocks.previous_hash'],
              'transaction_root': row['blocks.transaction_root'],
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
        'id': row['txn.id'],
        'version': row['txn.version'],
        'address': row['txn.address'],
        'contents': row['txn.contents'],
        'asset_ref': row['txn.asset_ref'],
        'merkel_proof': row['txn.merkel_proof'],
        'timestamp': row['txn.timestamp'],
        'signature': row['txn.signature'],
        'block': blockMap == null ? null : BlockModel.fromMap(blockMap)
      };
      TransactionModel transaction = TransactionModel.fromMap(transactionMap);
      transactions.add(transaction);
    }
    return transactions;
  }
}
