/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */
/// {@category SDK}
import 'package:sqlite3/sqlite3.dart';
import 'ownership_model.dart';

/// The repository for [OwnershipModel] persistence.
class OwnershipRepository {
  final Database _db;

  OwnershipRepository(this._db);
}
