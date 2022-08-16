import 'package:sqlite3/sqlite3.dart';
import 'xchain_model.dart';

class XchainRepository {
  static const table = 'xchain';

  final Database _db;

  XchainRepository(this._db);

  Future<void> createTable() async {
    _db.execute('''
      CREATE TABLE IF NOT EXISTS $table (
        xchain_id INTEGER PRIMARY KEY AUTO INCREMENT,
        last_checked INTEGER,
        uri TEXT NOT NULL UNIQUE,
      );
    ''');
  }

  void save(XchainModel xchain) {
    try {
      _db.execute("INSERT INTO $table VALUES (${xchain.toSqlValues()})");
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  List<XchainModel> getAll() {
    return _paged(0);
  }

  XchainModel? getById(int id) {
    List<XchainModel> xchains = _select(whereStmt: 'WHERE xchain_id = $id');
    return xchains.isNotEmpty ? xchains[0] : null;
  }

  XchainModel? getByUri(String uri) {
    List<XchainModel> xchains = _select(whereStmt: 'WHERE uri = ${uri.trim()}');
    return xchains.isNotEmpty ? xchains[0] : null;
  }

  List<XchainModel> getSince(DateTime since) {
    int sinceInSeconds = since.millisecondsSinceEpoch ~/ 1000;
    return _select(whereStmt: 'WHERE last_checked < $sinceInSeconds');
  }

  List<XchainModel> getAfter(DateTime since) {
    int sinceInSeconds = since.millisecondsSinceEpoch ~/ 1000;
    return _select(whereStmt: 'WHERE last_checked > $sinceInSeconds');
  }

  List<XchainModel> _paged(page, {String? whereStmt}) {
    List<XchainModel> pagedXchains = _select(page: page, whereStmt: whereStmt);
    if (pagedXchains.length == 100) pagedXchains.addAll(_paged(page + 1));
    return pagedXchains;
  }

  // TODO verificar where sem ser raw
  List<XchainModel> _select({int page = 0, String? whereStmt = 'WHERE 1=1'}) {
    int offset = page * 100;
    ResultSet results = _db.select('''
        SELECT *.$table as xchain
        FROM $table 
        $whereStmt
        OFFSET $offset LIMIT 100
        ''');
    List<XchainModel> xchains = [];
    for (final Row row in results) {
      xchains.add(XchainModel.fromMap(row));
    }
    return xchains;
  }

  void deleteById(int id) {
    _db.execute("DELETE FROM $table WHERE xchain_id = $id");
  }
}
