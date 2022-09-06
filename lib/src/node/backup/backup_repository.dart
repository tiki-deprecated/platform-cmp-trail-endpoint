import 'package:sqlite3/sqlite3.dart';

import 'backup_model.dart';

class BackupRepository {
  static const table = 'backup';

  static const collumnId = 'id';
  static const collumnAssetRef = 'asset_ref';
  static const collumnSignature = 'signature';
  static const collumnPayload = 'payload';
  static const collumnTimestamp = 'timestamp';

  final Database _db;

  BackupRepository(this._db) {
    createTable();
  }

  void createTable() async {
    _db.execute('''
      CREATE TABLE IF NOT EXISTS $table (
        $collumnId INTEGER PRIMARY KEY AUTO INCREMENT,
        $collumnAssetRef TEXT NOT NULL,
        $collumnSignature BLOB NOT NULL,
        $collumnPayload TEXT,
        $collumnTimestamp INTEGER,
      );
    ''');
  }

  void save(BackupModel backup) {
    _db.execute('''INSERT INTO $table VALUES (
        ${backup.id},
        '${backup.assetRef}',
        ${backup.signature},
        ${backup.payload == null ? null : "'${backup.payload}'"},
        ${backup.timestamp == null ? null : backup.timestamp!.millisecondsSinceEpoch ~/ 1000},
      );''');
  }

  List<BackupModel> getPending() {
    String where = 'WHERE timestamp IS NULL';
    return _select(whereStmt: where);
  }

  List<BackupModel> _select({String? whereStmt}) {
    ResultSet results = _db.select('''
        SELECT 
          $table.$collumnId
          $table.$collumnAssetRef
          $table.$collumnSignature
          $table.$collumnPayload
          $table.$collumnTimestamp
        FROM $table as backup
        ${whereStmt ?? 'WHERE 1=1'}
        ''');
    List<BackupModel> backups = [];
    for (final Row row in results) {
      Map<String, dynamic> bkpMap = {
        collumnId: row[collumnId],
        collumnAssetRef: row[collumnAssetRef],
        collumnSignature: row[collumnSignature],
        collumnPayload: row[collumnPayload],
        collumnTimestamp: row[collumnTimestamp]
      };
      BackupModel bkp = BackupModel.fromMap(bkpMap);
      backups.add(bkp);
    }
    return backups;
  }

  void update(BackupModel bkp) {}
}
