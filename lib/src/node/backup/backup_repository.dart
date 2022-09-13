import 'package:sqlite3/sqlite3.dart';

import 'backup_model.dart';

class BackupRepository {
  static const table = 'backup';

  static const columnPath = 'path';
  static const columnSignature = 'signature';
  static const columnTimestamp = 'timestamp';

  final Database _db;

  BackupRepository(this._db) {
    createTable();
  }

  void createTable() async {
    _db.execute('''
      CREATE TABLE IF NOT EXISTS $table (
        $columnPath TEXT NOT NULL,
        $columnSignature BLOB,
        $columnTimestamp INTEGER
      );
    ''');
  }

  void save(BackupModel backup) {
    _db.execute('INSERT INTO $table VALUES ( ?, ?, ? );', [
      backup.path,
      backup.signature,
      backup.timestamp == null
          ? null
          : backup.timestamp!.millisecondsSinceEpoch ~/ 1000
    ]);
  }

  void update(BackupModel backup) {
    _db.execute('''UPDATE $table SET 
        $columnTimestamp = ?, 
        $columnSignature = ?
        WHERE 
        $columnPath = ?;
      ;''', [
        backup.timestamp!.millisecondsSinceEpoch ~/ 1000,
        backup.signature,
        backup.path
      ]);
  }

  List<BackupModel> getPending() {
    String where = 'WHERE $columnTimestamp IS NULL';
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
        columnPath: row[columnPath],
        columnSignature: row[columnSignature],
        columnTimestamp: row[columnTimestamp],
      };
      BackupModel bkp = BackupModel.fromMap(bkpMap);
      backups.add(bkp);
    }
    return backups;
  }
}
