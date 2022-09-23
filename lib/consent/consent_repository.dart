// ignore_for_file: unused_field

/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */
/// {@category SDK}
import 'package:sqlite3/sqlite3.dart';
import 'consent_model.dart';

/// The repository for [ConsentModel] persistence.
class ConsentRepository {
  final Database _db;

  ConsentRepository(this._db);
}
