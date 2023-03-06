/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'cache/title/title_tag.dart';

/// Title Records describe a data asset and MUST contain a Pointer Record to
/// your system. [Learn more](https://docs.mytiki.com/docs/offer-customization)
/// about Title Records.
class TitleRecord {
  /// This record's id.
  String id;

  /// A Pointer Record identifying the asset
  String ptr;

  /// The origin from which the data was generated.
  String? origin;

  /// A list of search-friendly tags describing the asset.
  List<TitleTag> tags;

  /// A human-readable description of the asset.
  String? description;

  TitleRecord(this.id, this.ptr,
      {this.origin, this.tags = const [], this.description});
}
