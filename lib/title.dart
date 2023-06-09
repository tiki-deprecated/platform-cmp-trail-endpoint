/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/api.dart';

import 'cache/title/title_model.dart';
import 'cache/title/title_service.dart';
import 'cache/title/title_tag.dart';
import 'title_record.dart';
import 'utils/bytes.dart';

class Title {
  final TitleService _titleService;

  Title(this._titleService);

  /// Create a new [TitleRecord].
  ///
  /// Parameters:
  ///
  /// • [ptr] - The Pointer Records identifies data stored in your system,
  /// similar to a foreign key.
  /// [Learn more](https://docs.mytiki.com/docs/selecting-a-pointer-record)
  /// about selecting good pointer records.
  ///
  /// • [origin] - An optional override of the default [origin] specified in
  /// [init]. Follow a reverse-DNS syntax. _i.e. com.myco.myapp_
  ///
  /// • [tags] - A `List` of metadata tags included in the [TitleRecord]
  /// describing the asset, for your use in record search and filtering.
  /// [Learn more](https://docs.mytiki.com/docs/adding-tags)
  /// about adding tags.
  ///
  /// • [description] - A short, human-readable, description of
  /// the [TitleRecord] as a future reminder.
  ///
  /// Returns the created [TitleRecord]
  Future<TitleRecord> create(String ptr,
      {String? origin,
      List<TitleTag> tags = const [],
      String? description}) async {
    ptr = _hashPtr(ptr);
    TitleModel title = await _titleService.create(ptr,
        origin: origin, description: description, tags: tags);
    return title.toRecord();
  }

  /// Returns the [TitleRecord] for an [ptr] or null if the record is
  /// not found.
  TitleRecord? get(String ptr, {String? origin}) {
    ptr = _hashPtr(ptr);
    TitleModel? model = _titleService.getByPtr(ptr, origin: origin);
    if (model == null) return null;
    return model.toRecord();
  }

  /// Returns the [TitleRecord] for an [id] or null if the record is
  /// not found.
  TitleRecord? id(String id) {
    TitleModel? model = _titleService.getById(Bytes.base64UrlDecode(id));
    if (model == null) return null;
    return model.toRecord();
  }

  /// Helper method to SHA3-256 hash customer provided Pointer Records ([ptr]).
  String _hashPtr(String ptr) => base64
      .encode(Digest("SHA3-256").process(Uint8List.fromList(utf8.encode(ptr))));
}
