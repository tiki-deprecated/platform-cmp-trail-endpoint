import 'package:sqlite3/sqlite3.dart';

import 'backup_model.dart';

class BackupRepository {

  static const table = 'backup';

  static const columnId = 'id';
  static const collumnAssetId = 'asset_id';
  static const collumnAssetType = 'asset_type';
  static const collumnSignature = 'signature';
  static const collumnTimestamp = 'timestamp';

  final Database _db;

  BackupRepository(this._db) {
    createTable();
  }

  void createTable() async {
    _db.execute('''
      CREATE TABLE IF NOT EXISTS $table (
        $columnId INTEGER PRIMARY KEY,
        $collumnAssetId TEXT,
        $collumnAssetType TEXT NOT NULL,
        $collumnSignature BLOB NOT NULL,
        $collumnTimestamp INTEGER
      );
    ''');
  }

  void save(BackupModel backup) {
    _db.execute('''INSERT INTO $table VALUES (
        null,
        '${backup.assetId}',
        '${backup.assetType}',
        ${backup.signature},
        ${backup.timestamp == null ? null : backup.timestamp!.millisecondsSinceEpoch ~/ 1000}
      );''');
  }

  void update(BackupModel backup) {
    _db.execute('''UPDATE $table SET
        $collumnTimestamp = ${backup.timestamp!.millisecondsSinceEpoch ~/ 1000}
        WHERE 
        $collumnAssetId = ${backup.assetId} AND
        $collumnAssetType = ${backup.assetType.value};
      ;''');
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
        collumnAssetId: row[collumnAssetId],
        collumnAssetType: row[collumnAssetType],
        collumnSignature: row[collumnSignature],
        collumnTimestamp: row[collumnTimestamp],
      };
      BackupModel bkp = BackupModel.fromMap(bkpMap);
      backups.add(bkp);
    }
    return backups;
  }
}
