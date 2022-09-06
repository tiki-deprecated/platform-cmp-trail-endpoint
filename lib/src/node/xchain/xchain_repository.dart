import 'package:sqlite3/sqlite3.dart';

import 'xchain_model.dart';

class XchainRepository {
  final Database _db;

  static const String table = 'xchain';
  static const String collumnAddress = 'address';
  static const String collumnPubkey = 'pubkey';
  static const String collumnLastChecked = 'last_checked';

  XchainRepository(this._db) {
    createTable();
  }

  void createTable() async {
    _db.execute('''
      CREATE TABLE IF NOT EXISTS $table (
        $collumnAddress TEXT PRIMARY KEY,
        $collumnPubkey TEXT NOT NULL,
        $collumnLastChecked
      );
    ''');
  }

  void save(XchainModel xchain) => _db.execute('''INSERT INTO $table VALUES (
      '${xchain.address}',
      '${xchain.pubkey}'
      ${xchain.lastChecked == null ? null : "${xchain.lastChecked!.millisecondsSinceEpoch ~/ 1000}"}
    );''');

  XchainModel? getByAddress(String address) {
    List<XchainModel> xchains =
        _select(whereStmt: 'WHERE $collumnAddress = $address');
    return xchains.isNotEmpty ? xchains.first : null;
  }

  void updateLastChecked(DateTime lastChecked, String address) {
    XchainModel xchain = getByAddress(address)!;
    _db.execute('''UPDATE $table 
      SET last_checked = ${lastChecked.millisecondsSinceEpoch ~/ 1000}'
      WHERE $collumnAddress = ${xchain.address};
      ''');
  }

  List<XchainModel> _select({String whereStmt = 'WHERE 1=1'}) {
    ResultSet results = _db.select('''
        SELECT *
        FROM $table 
        $whereStmt;
        ''');
    List<XchainModel> xchains = [];
    for (final Row row in results) {
      xchains.add(XchainModel.fromMap(row));
    }
    return xchains;
  }
}
