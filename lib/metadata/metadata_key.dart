/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

enum MetadataKey {
  dbVersion('db_version');

  const MetadataKey(this.value);

  final String value;
}
