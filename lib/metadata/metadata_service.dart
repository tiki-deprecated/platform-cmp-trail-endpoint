/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:sqlite3/sqlite3.dart';

import 'metadata_key.dart';
import 'metadata_repository.dart';

class MetadataService {
  final MetadataRepository _repository;

  MetadataService(Database db) : _repository = MetadataRepository(db);

  void save(MetadataKey key, String value) => _repository.save(key, value);

  String get(MetadataKey key) => _repository.get(key);

  void update(MetadataKey key, String value) => _repository.update(key, value);
}
