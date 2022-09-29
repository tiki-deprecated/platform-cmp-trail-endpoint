/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */
/// {@category Node}
import 'dart:convert';
import 'dart:typed_data';

import 'package:sqlite3/sqlite3.dart';

import '../../utils/utils.dart';
import 'block_model.dart';

/// The repository for [BlockModel] persistance in [Database].
class BlockRepository {
  /// The [BlockModel] table name in [_db].
  static const table = 'block';

  /// The [BlockModel.id] column.
  static const columnId = 'id';

  /// The [BlockModel.version] column.
  static const columnVersion = 'version';

  /// The [BlockModel.previousHash] column.
  static const columnPreviousHash = 'previous_hash';

  /// The [BlockModel.transactionRoot] column.
  static const columnTransactionRoot = 'transaction_root';

  /// The [BlockModel.timestamp] column.
  static const columnTimestamp = 'timestamp';

  /// The xchain address.
  static const columnXchain = 'xchain';

  /// The [Database] used to persist [BlockModel].
  final Database _db;

  /// Builds a [BlockRepository] that will use [_db] for persistence.
  ///
  /// It calls [createTable] to make sure the table exists.
  BlockRepository(this._db) {
    createTable();
  }

  /// Builds a [BlockRepository] that will use [_db] for persistence.
  ///
  /// It calls [createTable] to make sure the table exists.
  void createTable() => _db.execute('''
    CREATE TABLE IF NOT EXISTS $table (
      $columnId BLOB PRIMARY KEY NOT NULL,
      $columnVersion INTEGER NOT NULL,
      $columnPreviousHash BLOB,
      $columnTransactionRoot BLOB,
      $columnXchain BLOB,
      $columnTimestamp INTEGER);
    ''');

  /// Persists a [block] in the local [_db].
  void save(BlockModel block, {Uint8List? xchain}) => _db.execute('''
    INSERT INTO $table 
    VALUES (?, ?, ?, ?, ?, ?);
    ''', [
        block.id,
        block.version,
        block.previousHash,
        block.transactionRoot,
        xchain,
        block.timestamp.millisecondsSinceEpoch
      ]);

  /// Gets a [BlockModel] by its [BlockModel.id].
  BlockModel? getById(Uint8List id) {
    List<BlockModel> blocks = _select(
        whereStmt: "WHERE $table.$columnId = x'${Bytes.hexEncode(id)}'");
    return blocks.isNotEmpty ? blocks[0] : null;
  }

  /// Gets the last persisted [BlockModel].
  BlockModel? getLast() {
    List<BlockModel> blocks = _select(last: true, page: 0, pageSize: 1);
    return blocks.isNotEmpty ? blocks.first : null;
  }

  List<String> getAllIds(Uint8List address) {
    ResultSet results = _db.select('''
      SELECT $columnId from $table 
      WHERE $columnXchain = x'${Bytes.hexEncode(address)}'; ''');
    return results
        .map<String>((row) => base64Url.encode(row[columnId]))
        .toList();
  }

  List<BlockModel> _select(
      {int? page, int pageSize = 100, String? whereStmt, bool last = false}) {
    String limit = page != null ? 'LIMIT ${page * pageSize},$pageSize' : '';
    ResultSet results = _db.select('''
      SELECT 
        $table.$columnId as '$table.$columnId',
        $table.$columnVersion as '$table.$columnVersion',
        $table.$columnPreviousHash as '$table.$columnPreviousHash',
        $table.$columnTransactionRoot as '$table.$columnTransactionRoot',
        $table.$columnXchain as '$table.$columnXchain',
        $table.$columnTimestamp as '$table.$columnTimestamp'
      FROM $table
      ${whereStmt ?? ''}
      ORDER BY oid ${last ? 'DESC' : 'ASC'};
      $limit
      ''');
    List<BlockModel> blocks = [];
    for (final Row row in results) {
      Map<String, dynamic> blockMap = {
        columnId: row['$table.$columnId'],
        columnVersion: row['$table.$columnVersion'],
        columnPreviousHash: row['$table.$columnPreviousHash'],
        columnXchain: row['$table.$columnXchain'],
        columnTransactionRoot: row['$table.$columnTransactionRoot'],
        columnTimestamp: row['$table.$columnTimestamp'],
      };
      BlockModel block = BlockModel.fromMap(blockMap);
      blocks.add(block);
    }
    return blocks;
  }
}
