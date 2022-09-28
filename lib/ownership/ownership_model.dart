/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */
/// {@category SDK}
import 'dart:convert';
import 'dart:typed_data';

import '../tiki_sdk_data_type_enum.dart';
import '../utils/utils.dart';
import 'ownership_repository.dart';

/// The registry of ownership to a given [source] point, pool, or stream.
class OwnershipModel {
  /// The identification of the data point, pool or stream.
  String source;

  /// The list of types the source holds.
  List<TikiSdkDataTypeEnum> types;

  /// The origin from which the data was generated.
  String origin;

  /// The transaction id of this registry.
  Uint8List? transactionId;

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

  Uint8List serialize() {
    String jsonTypes = jsonEncode(
        types.map<String>((TikiSdkDataTypeEnum t) => t.val).toList());
    return (BytesBuilder()
          ..add(CompactSize.encode(Uint8List.fromList(source.codeUnits)))
          ..add(CompactSize.encode(Uint8List.fromList(jsonTypes.codeUnits)))
          ..add(CompactSize.encode(Uint8List.fromList(origin.codeUnits)))
          ..add(CompactSize.encode(about == null
              ? Uint8List(1)
              : Uint8List.fromList(about!.codeUnits))))
        .toBytes();
  }

  static OwnershipModel deserialize(Uint8List serialized) {
    List<Uint8List> unserialized = CompactSize.decode(serialized);
    return OwnershipModel(
        source: String.fromCharCodes(unserialized[0]),
        types: jsonDecode(String.fromCharCodes(unserialized[1]))
            .map<TikiSdkDataTypeEnum>((val) => TikiSdkDataTypeEnum.fromValue(val)).toList(),
        origin: String.fromCharCodes(unserialized[2]),
        about: String.fromCharCodes(unserialized[3]));
  }

}
