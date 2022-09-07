import 'package:sqlite3/sqlite3.dart';

import 'metadata_key.dart';

class MetadataRepository {
  static const table = 'metadata';

  static const columnKey = 'key';
  static const columnValue = 'value';

  final Database _db;

  MetadataRepository(this._db) {
    createTable();
  }

  void createTable() async {
    _db.execute('''
      CREATE TABLE IF NOT EXISTS $table (
        $columnKey TEXT PRIMARY KEY,
        $columnValue TEXT,
      );
    ''');
  }

  void save(MetadataKey key, String value) {
    _db.execute('''INSERT INTO $table VALUES (
        '${key.value}',
        '$value'
      );''');
  }

  void update(MetadataKey key, String value) {
    _db.execute('''UPDATE $table SET
        $columnValue = '$value'
        WHERE 
        $columnKey = ${key.value}
      ;''');
  }

  String get(MetadataKey key) {
    return _db.select('''SELECT $columnValue FROM $table
      WHERE $columnKey = "${key.value}"''')[0][columnValue];
  }
}
