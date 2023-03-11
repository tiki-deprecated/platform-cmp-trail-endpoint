/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */
import 'dart:typed_data';

import '../../node/node_service.dart';
import '../../node/transaction/transaction_model.dart';
import '../content_schema.dart';
import 'title_model.dart';
import 'title_repository.dart';
import 'title_tag.dart';

/// The service to manage [TitleModel]s
class TitleService {
  /// The default origin for all titles.
  final String _defaultOrigin;

  final TitleRepository _repository;

  final NodeService nodeService;

  TitleService(this._defaultOrigin, this.nodeService, db)
      : _repository = TitleRepository(db);

  /// Creates an on-chain [TitleModel].
  ///
  /// This method creates a new pending transaction that will be committed
  /// during assembly of the next block in the chain.
  ///
  /// If no [origin] is provided the default [origin] will be used
  Future<TitleModel> create(String ptr,
      {String? origin,
      String? description,
      List<TitleTag> tags = const []}) async {
    TitleModel? titleRecord = getByPtr(ptr, origin: origin);
    if (titleRecord != null) {
      throw 'Title already granted for $ptr and $origin. ${titleRecord.toString()}';
    }
    titleRecord = TitleModel(origin ?? _defaultOrigin, ptr,
        description: description, tags: tags);
    Uint8List contents = (BytesBuilder()
          ..add(ContentSchema.title.toCompactSize())
          ..add(titleRecord.serialize()))
        .toBytes();
    TransactionModel transaction = await nodeService.write(contents);
    titleRecord.transactionId = transaction.id;
    _repository.save(titleRecord);
    return titleRecord;
  }

  /// Returns a [TitleModel] from the local cache using its [ptr] and [origin].
  ///
  /// If no [origin] is provided the [_defaultOrigin] will be used
  TitleModel? getByPtr(String ptr, {String? origin}) =>
      _repository.getByPtr(ptr, origin ?? _defaultOrigin);

  /// Returns a [TitleModel] from the local cache using its [id].
  TitleModel? getById(Uint8List id) => _repository.getById(id);

  void add(TitleModel title) => _repository.save(title);
}
