/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:typed_data';

import '../tiki_sdk_data_type_enum.dart';
import '../utils/utils.dart';
import 'ownership_repository.dart';

/// The Ownership NFT. The registry of ownership to a given data point, pool, or
/// stream.
class OwnershipModel {
  /// The identification of the source.
  String source;

  /// The type of the data source: data point, pool or stream.
  TikiSdkDataTypeEnum type;

  /// The origin from which the data was generated.
  String origin;

  /// The transaction id of this registry.
  Uint8List? transactionId;

  /// The description about the data.
  String? about;

  /// The kinds of data this contains.
  List<String> contains;

  OwnershipModel({
    this.transactionId,
    required this.source,
    required this.type,
    required this.origin,
    this.contains = const [],
    this.about,
  });

  /// Builds a [OwnershipModel] from a [map].
  ///
  /// It is used mainly for retrieving data from [OwnershipRepository].
  /// The map strucure is
  /// ```
  ///   Map<String, dynamic> map = {
  ///     OwnershipRepository.columnSource : String,
  ///     OwnershipRepository.columnType : TikiSdkTypeEnum,
  ///     OwnershipRepository.columnOrigin : String,
  ///     OwnershipRepository.columnAbout : String,
  ///     OwnershipRepository.columnContains : List<String>,
  ///     OwnershipRepository.columnTransactionId : Uint8List,
  ///    }
  /// ```
  OwnershipModel.fromMap(Map<String, dynamic> map)
      : source = map[OwnershipRepository.columnSource],
        type = map[OwnershipRepository.columnType],
        origin = map[OwnershipRepository.columnOrigin],
        about = map[OwnershipRepository.columnAbout],
        contains = map[OwnershipRepository.columnContains],
        transactionId = map[OwnershipRepository.columnTransactionId];

  /// Serializes the contents to be recorded in the blockchain.
  Uint8List serialize() {
    String jsonContains = jsonEncode(contains);
    return (BytesBuilder()
          ..add(CompactSize.encode(Uint8List.fromList(source.codeUnits)))
          ..add(CompactSize.encode(Uint8List.fromList(type.val.codeUnits)))
          ..add(CompactSize.encode(Uint8List.fromList(origin.codeUnits)))
          ..add(CompactSize.encode(about == null
              ? Uint8List(1)
              : Uint8List.fromList(about!.codeUnits)))
          ..add(CompactSize.encode(Uint8List.fromList(jsonContains.codeUnits))))
        .toBytes();
  }

  /// Converts this to JSON String
  String toJson() => jsonEncode({
        source: source,
        type: type.val,
        origin: origin,
        about: about,
        contains: contains,
        transactionId: transactionId != null
            ? Bytes.base64UrlEncode(transactionId!)
            : null,
      });

  /// Deserializes the contents that was loaded from the blockchain.
  static OwnershipModel deserialize(Uint8List serialized) {
    List<Uint8List> unserialized = CompactSize.decode(serialized);
    return OwnershipModel(
        source: String.fromCharCodes(unserialized[0]),
        type: TikiSdkDataTypeEnum.fromValue(
            String.fromCharCodes(unserialized[1])),
        origin: String.fromCharCodes(unserialized[2]),
        about: String.fromCharCodes(unserialized[3]),
        contains: jsonDecode(String.fromCharCodes(unserialized[4]))
            .map<String>((e) => e.toString())
            .toList());
  }
}
