/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */
/// The metadata library for key-value metadata.
library metadata;

export 'metadata_key.dart';
export 'metadata_repository.dart';
export 'metadata_service.dart';

import 'package:sqlite3/sqlite3.dart';

import 'metadata_key.dart';
import 'metadata_repository.dart';
/// The service for storing metadata as key-value pairs.
class MetadataService {
  final MetadataRepository _repository;

  MetadataService(Database db) : _repository = MetadataRepository(db);

  void save(MetadataKey key, String value) => _repository.save(key, value);

  String get(MetadataKey key) => _repository.get(key);

  void update(MetadataKey key, String value) => _repository.update(key, value);
}
