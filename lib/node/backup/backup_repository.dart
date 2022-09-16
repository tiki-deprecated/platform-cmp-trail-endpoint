/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */
/// {@category Node}
import 'package:sqlite3/sqlite3.dart';

import 'backup_model.dart';

/// The repository for [BackupModel] persistance in [Database].
class BackupRepository {
  /// The [BackupModel] table name in [_db].
  static const table = 'backup';

  /// The [BackupModel.path] collumn
  static const columnPath = 'path';

  /// The [BackupModel.signature] collumn
  static const columnSignature = 'signature';

  /// The [BackupModel.timestamp] collumn
  static const columnTimestamp = 'timestamp';

  /// The [Database] used to persist [BackupModel].
  final Database _db;

  /// Builds a [BackupRepository] that will use [_db] for persistence.
  ///
  /// It calls [createTable] to make sure the table exists.
  BackupRepository(this._db) {
    createTable();
  }

  /// Creates the [BackupRepository.table] if it does not exist.
  void createTable() async {
    _db.execute('''
      CREATE TABLE IF NOT EXISTS $table (
        $columnPath TEXT NOT NULL,
        $columnSignature BLOB,
        $columnTimestamp INTEGER
      );
    ''');
  }

  /// Persists [backup] in [_db].
  void save(BackupModel backup) {
    _db.execute('INSERT INTO $table VALUES ( ?, ?, ? );', [
      backup.path,
      backup.signature,
      backup.timestamp == null
          ? null
          : backup.timestamp!.millisecondsSinceEpoch ~/ 1000
    ]);
  }

  /// Updates the persisted [BackupModel] by adding [BackupModel.signature]
  /// and [BackupModel.timestamp]
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

  /// Gets all pending [BackupModel]
  ///
  /// A [BackupModel] is considered pending if [BackupModel.timestamp] is null.
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
