import 'package:sqlite3/sqlite3.dart';
import '../../utils/page_model.dart';
import '../../utils/utils.dart';
import '../xchain/xchain_model.dart';
import '../xchain/xchain_repository.dart';
import 'block_model.dart';

class BlockRepository {
  static const table = 'blocks';
  final Database _db;

  BlockRepository({Database? db}) : _db = db ?? sqlite3.openInMemory() {
    createTable();
  }

  void createTable() async {
    _db.execute('''
      CREATE TABLE IF NOT EXISTS $table (
          seq INTEGER AUTO INCREMENT,
          id TEXT PRIMARY KEY,
          version INTEGER NOT NULL,
          previous_hash TEXT NOT NULL UNIQUE,
          xchain_id INTEGER,
          transaction_root TEXT NOT NULL,
          transaction_count INTEGER NOT NULL,
          timestamp INTEGER NOT NULL
      );
    ''');
  }

  void save(BlockModel block) {
    _db.execute('''INSERT INTO $table VALUES (
        ${block.seq}, 
        ${uint8ListToBase64Url(block.id, nullable: false, addQuotes: true )}, 
        ${block.version}, 
        ${uint8ListToBase64Url(block.previousHash, nullable: false, addQuotes: true )},
        ${block.xchain == null ? null : '${block.xchain!.id}'}, 
        ${uint8ListToBase64Url(block.transactionRoot, nullable: false, addQuotes: true )},
        ${block.transactionCount}, 
        ${block.timestamp.millisecondsSinceEpoch ~/ 1000});''');
  }

  PageModel<BlockModel> getByXchain(XchainModel xchainModel, {int? page}) {
    String whereStmt = 'WHERE xchain_id = ${xchainModel.id}';
    List<BlockModel> blocks = _select(page: page, whereStmt: whereStmt);
    return PageModel<BlockModel>(page ?? 0, blocks);
  }

  PageModel<BlockModel> getLocal({int? page}) {
    String whereStmt = 'WHERE xchain_id IS NULL';
    List<BlockModel> blocks = _select(page: page, whereStmt: whereStmt);
    return PageModel<BlockModel>(page ?? 0, blocks);
  }

  BlockModel? getById(String id) {
    List<BlockModel> blocks = _select(whereStmt: "WHERE blocks.id = '$id'");
    return blocks.isNotEmpty ? blocks[0] : null;
  }

  BlockModel? getLast({XchainModel? xchainModel}) {
    String where = "WHERE xchain_id = '${xchainModel?.id}'";
    if (xchainModel == null) {
      where = "WHERE xchain_id IS NULL";
    }
    List<BlockModel> blocks = _select(whereStmt: where);
    return blocks.isNotEmpty ? blocks.first : null;
  }

  List<BlockModel> getAfter(DateTime since, XchainModel xchain) {
    int sinceInSeconds = since.millisecondsSinceEpoch ~/ 1000;
    return _select(whereStmt: 'WHERE timestamp >= $sinceInSeconds');
  }

  List<BlockModel> _select(
      {int? page, String whereStmt = 'WHERE 1=1', bool last = false}) {
    String limit = page != null ? 'LIMIT ${page * 100},100' : '';
    ResultSet results = _db.select('''
        SELECT 
          blocks.id as 'blocks.id',
          blocks.version as 'blocks.version',
          blocks.previous_hash as 'blocks.previous_hash',
          blocks.xchain_id as 'blocks.xchain_id',
          blocks.transaction_root as 'blocks.transaction_root',
          blocks.transaction_count as 'blocks.transaction_count',
          blocks.timestamp as 'blocks.timestamp',
          xchains.id as 'xchains.id',
          xchains.last_checked as 'xchains.last_checked',
          xchains.uri as 'xchains.uri'
        FROM $table as blocks
        LEFT JOIN ${XchainRepository.table} as xchains
        ON blocks.xchain_id = xchains.id
        $whereStmt
        ${last ? 'ORDER BY blocks.seq DESC' : ''};
        $limit
        ''');
    List<BlockModel> blocks = [];
    for (final Row row in results) {
      Map<String, dynamic> blockMap = {
        'seq': row['seq'],
        'id': base64UrlToUint8List(row['blocks.id']),
        'version': row['blocks.version'],
        'previous_hash': base64UrlToUint8List(row['blocks.previous_hash']),
        'transaction_root': base64UrlToUint8List(row['blocks.transaction_root']),
        'transaction_count': row['blocks.transaction_count'],
        'timestamp': row['blocks.timestamp']
      };
      blockMap['xchain'] = row['xchains.id'] == null
          ? null
          : XchainModel.fromMap({
              'id': row['xchains.id'],
              'last_checked': row['xchains.last_checked'],
              'uri': row['xchains.uri'],
            });
      BlockModel block = BlockModel.fromMap(blockMap);
      blocks.add(block);
    }
    return blocks;
  }
}
