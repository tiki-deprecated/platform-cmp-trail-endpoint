/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */
/// {@category SDK}
import '../tiki_sdk_data_type_enum.dart';

/// The registry of ownership to a given [source] point, pool, or stream.
class OwnershipModel {
  /// The identification of the data potin, pool or stream.
  String source;

  /// The list of types the source holds.
  List<TikiSdkDataTypeEnum> type;

  /// The origin from which the data was generated.
  String origin;

  /// The transaction id of this registry.
  late String transactionId;

  /// A description about the data.
  String? about;

  /// The path to the ownership register in the chain
  String? path;

  OwnershipModel(
      {required this.source,
      required this.type,
      required this.origin,
      this.about,
      this.path});
}
