/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'cache/title/title_tag.dart';

/// Title Records describe a data asset and MUST contain a Pointer Record to
/// the raw data (often stored in your system).
class TitleRecord {
  /// This record's id.
  String id;

  /// The hashed (SHA3-256, Base64) Pointer Record identifying the asset.
  /// Similar to a foreign key,
  /// [learn more](https://docs.mytiki.com/docs/selecting-a-pointer-record)
  ///  about selecting good pointer records.
  String hashedPtr;

  /// The origin where the data was created.
  String? origin;

  /// A list of search-friendly metadata tags describing the asset.
  /// [Learn more](https://docs.mytiki.com/docs/adding-tags)
  /// about the various tags.
  List<TitleTag> tags;

  /// An optional, human-readable description of the asset.
  String? description;

  TitleRecord(this.id, this.hashedPtr,
      {this.origin, this.tags = const [], this.description});
}
