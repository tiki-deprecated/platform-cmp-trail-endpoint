import 'package:sqlite3/sqlite3.dart';

import 'backup_model.dart';

class BackupRepository {
  static const table = 'backup';

  static const columnId = 'id';
  static const columnAssetId = 'asset_id';
  static const columnAssetType = 'asset_type';
  static const columnSignature = 'signature';
  static const columnTimestamp = 'timestamp';

  final Database _db;

  BackupRepository(this._db) {
    createTable();
  }

  void createTable() async {
    _db.execute('''
      CREATE TABLE IF NOT EXISTS $table (
        $columnId INTEGER PRIMARY KEY,
        $columnAssetId TEXT,
        $columnAssetType TEXT NOT NULL,
        $columnSignature BLOB NOT NULL,
        $columnTimestamp INTEGER
      );
    ''');
  }

  void save(BackupModel backup) {
    _db.execute('INSERT INTO $table VALUES ( ?, ?, ?, ?, ? );', [
      null,
      backup.assetId,
      backup.assetType.value,
      backup.signature,
      backup.timestamp == null
          ? null
          : backup.timestamp!.millisecondsSinceEpoch ~/ 1000
    ]);
  }

  void update(BackupModel backup) {
    _db.execute('''UPDATE $table SET $columnTimestamp = ? 
        WHERE 
        $columnAssetId = ? AND $columnAssetType = ?;
      ;''', [
      backup.timestamp!.millisecondsSinceEpoch ~/ 1000,
      backup.assetId,
      backup.assetType.value
    ]);
  }

  List<BackupModel> getPending() {
    String where = 'WHERE timestamp IS NULL';
    return _select(whereStmt: where);
  }

  List<BackupModel> _select({String? whereStmt}) {
    ResultSet results = _db.select('''
        SELECT * FROM $table
        ${whereStmt ?? 'WHERE 1=1'}
        ''');
    List<BackupModel> backups = [];
    for (final Row row in results) {
      Map<String, dynamic> bkpMap = {
        columnId: row[columnId],
        columnAssetId: row[columnAssetId],
        columnAssetType: row[columnAssetType],
        columnSignature: row[columnSignature],
        columnTimestamp: row[columnTimestamp],
      };
      BackupModel bkp = BackupModel.fromMap(bkpMap);
      backups.add(bkp);
    }
    return backups;
  }
}
