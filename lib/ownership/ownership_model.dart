/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */
/// {@category SDK}
import '../tiki_sdk_data_type_enum.dart';
import 'ownership_repository.dart';

/// The registry of ownership to a given [source] point, pool, or stream.
class OwnershipModel {
  /// The identification of the data potin, pool or stream.
  String source;

  /// The list of types the source holds.
  List<TikiSdkDataTypeEnum> types;

  /// The origin from which the data was generated.
  String origin;

  /// The transaction id of this registry.
  String? transactionId;

  /// A description about the data.
  String? about;

  OwnershipModel({
    this.transactionId,
    required this.source,
    required this.types,
    required this.origin,
    this.about,
  });

  OwnershipModel.fromMap(Map<String, dynamic> map)
      : source = map[OwnershipRepository.columnSource],
        types = map[OwnershipRepository.columnTypes],
        origin = map[OwnershipRepository.columnOrigin],
        about = map[OwnershipRepository.columnAbout],
        transactionId = map[OwnershipRepository.columnTransactionId];
}
