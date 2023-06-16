/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:sqlite3/common.dart';

import 'backup_model.dart';

/// The repository for [BackupModel] persistence in [CommonDatabase].
class BackupRepository {
  /// The [BackupModel] table name in [_db].
  static const table = 'backup';

  /// The [BackupModel.path] column
  static const columnPath = 'path';

  /// The [BackupModel.signature] column
  static const columnSignature = 'signature';

  /// The [BackupModel.timestamp] column
  static const columnTimestamp = 'timestamp';

  /// The [CommonDatabase] used to persist [BackupModel].
  final CommonDatabase _db;

  /// Builds a [BackupRepository] that will use [_db] for persistence.
  ///
  /// It calls [_createTable] to make sure the table exists.
  BackupRepository(this._db) {
    _createTable();
  }

  /// Creates the [BackupRepository.table] if it does not exist.
  void _createTable() => _db.execute('''
    CREATE TABLE IF NOT EXISTS $table (
      $columnPath TEXT NOT NULL,
      $columnSignature BLOB,
      $columnTimestamp INTEGER
      );
    ''');

  /// Persists a [backup] in [_db].
  void save(BackupModel backup) => _db.execute('''
    INSERT INTO $table 
    VALUES ( ?, ?, ? );
    ''', [
        backup.path,
        backup.signature,
        backup.timestamp == null
            ? null
            : backup.timestamp!.millisecondsSinceEpoch
      ]);

  /// Updates the persisted [BackupModel] by adding [BackupModel.signature]
  /// and [BackupModel.timestamp]
  void update(BackupModel backup) {
    _db.execute('''
      UPDATE $table 
      SET
        $columnTimestamp = ?, 
        $columnSignature = ?
      WHERE $columnPath = ?;
      ''', [
      backup.timestamp!.millisecondsSinceEpoch,
      backup.signature,
      backup.path
    ]);
  }

  /// Gets all pending [BackupModel]
  ///
  /// A [BackupModel] is considered pending if [BackupModel.timestamp] is null.
  List<BackupModel> getPending() =>
      _select(whereStmt: 'WHERE $columnTimestamp IS NULL');

  /// Gets a [BackupModel] registry by its [path].
  BackupModel? getByPath(String path) {
    List<BackupModel> bkups = _select(whereStmt: "WHERE $columnPath = '$path'");
    return bkups.isNotEmpty ? bkups.first : null;
  }

  List<BackupModel> _select({String? whereStmt}) {
    ResultSet results = _db.select('''
      SELECT 
        $table.$columnPath as '$columnPath',
        $table.$columnSignature as '$columnSignature',
        $table.$columnTimestamp as '$columnTimestamp'
      FROM $table
      ${whereStmt ?? ''};
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
