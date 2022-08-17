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
          id INTEGER PRIMARY KEY,
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

  void save(TransactionModel transaction) {
    try {
      _db.execute("INSERT INTO $table VALUES (${transaction.toSqlValues()});");
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  List<TransactionModel> getByBlock(BlockModel block) {
    String whereStmt = 'WHERE block_id = ${block.id}';
    return _paged(0, whereStmt: whereStmt);
  }

  TransactionModel? getById(int id) {
    List<TransactionModel> transactions =
        _select(whereStmt: 'WHERE block_id = $id');
    return transactions.isNotEmpty ? transactions[0] : null;
  }

  List<TransactionModel> getByAssetRef(String assetRef) {
    List<TransactionModel> transactions =
        _select(whereStmt: 'WHERE previous_hash = $assetRef');
    return transactions;
  }

  List<TransactionModel> _paged(page, {String? whereStmt}) {
    List<TransactionModel> pagedTransactions =
        _select(page: page, whereStmt: whereStmt);
    if (pagedTransactions.length == 100)
      pagedTransactions.addAll(_paged(page + 1));
    return pagedTransactions;
  }

  // TODO verificar where sem ser raw
  List<TransactionModel> _select({int page = 0, String? whereStmt}) {
    int offset = page * 100;
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
        INNER JOIN ${BlockRepository.table} as blocks
        ON txn.block_id = blocks.id
        INNER JOIN ${XchainRepository.table} as xchains
        ON blocks.xchain_id = xchains.id 
        ${whereStmt ?? ''}
        LIMIT $offset,100;
        ''');
    List<TransactionModel> transactions = [];
    for (final Row row in results) {
      Map<String, dynamic> blockMap = {
        'id': row['blocks.id'],
        'version': row['blocks.version'],
        'previous_hash': row['blocks.previous_hash'],
        'transaction_root': row['blocks.transaction_root'],
        'transaction_count': row['blocks.transaction_count'],
        'timestamp': row['blocks.timestamp'],
        'xchain': XchainModel.fromMap({
          'id': row['xchains.id'],
          'last_checked': row['xchains.last_checked'],
          'uri': row['xchains.uri'],
        })
      };
      Map<String, dynamic> transactionMap = {
        'id': row['txn.id'],
        'version': row['txn.version'],
        'address': row['txn.address'],
        'contents': row['txn.contents'],
        'asset_ref': row['txn.asset_ref'],
        'merkel_proof': row['txn.merkel_proof'],
        'timestamp': row['txn.timestamp'],
        'signature': row['txn.signature'],
        'block': BlockModel.fromMap(blockMap)
      };
      TransactionModel transaction = TransactionModel.fromMap(transactionMap);
      transactions.add(transaction);
    }
    return transactions;
  }
}
