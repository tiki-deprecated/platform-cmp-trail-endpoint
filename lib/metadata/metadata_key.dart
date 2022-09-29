/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

/// The standard keys for persisting metadata.
enum MetadataKey {
  /// Database version
  dbVersion('db_version');

  const MetadataKey(this.value);

  final String value;
}
