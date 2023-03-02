/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:typed_data';

import '../../utils/bytes.dart';
import '../../utils/compact_size.dart';
import '../title/title_record.dart';
import 'license_repository.dart';
import 'license_use.dart';

/// Describes the license for an asset ([TitleRecord]).
class LicenseRecord {
  /// The [TitleRecord] transactionId
  Uint8List title;

  /// A list describing how an asset can be used
  List<LicenseUse> uses;

  /// The legal terms for with the license
  String terms;

  /// A human-readable description of the license
  String? description;

  /// The transaction id of this record
  Uint8List? transactionId;

  /// The date when the license expires
  DateTime? expiry;

  LicenseRecord(this.title, this.uses, this.terms,
      {this.description, this.transactionId, this.expiry});

  /// Construct a [LicenseRecord] from a [map].
  ///
  /// Primary use is [LicenseRepository] object marshalling.
  LicenseRecord.fromMap(Map<String, dynamic> map)
      : title = map[LicenseRepository.columnTitle],
        uses = map[LicenseRepository.columnUses]
            ?.map<LicenseUse>((use) => LicenseUse.fromMap(use))
            .toList(),
        terms = map[LicenseRepository.columnTerms],
        description = map[LicenseRepository.columnDescription],
        transactionId = map[LicenseRepository.columnTransactionId],
        expiry = map[LicenseRepository.columnExpiry] != null
            ? DateTime.fromMillisecondsSinceEpoch(
                map[LicenseRepository.columnExpiry])
            : null;

  /// Converts this to Map
  ///
  /// Primary use is [LicenseRepository] object marshalling.
  Map toMap() => {
        LicenseRepository.columnTitle: title,
        LicenseRepository.columnUses: uses.map((use) => use.toMap()).toList(),
        LicenseRepository.columnTerms: terms,
        LicenseRepository.columnDescription: description,
        LicenseRepository.columnTransactionId: transactionId,
        LicenseRepository.columnExpiry: expiry?.millisecondsSinceEpoch
      };

  /// Serializes this to binary.
  ///
  /// Primary use is on-chain storage. The [transaction_id] and [title] are not
  /// represented in the serialized output.
  Uint8List serialize() {
    String jsonUses = jsonEncode(uses.map((use) => use.toMap()).toList());
    return (BytesBuilder()
          ..add(CompactSize.encode(Bytes.utf8Encode(jsonUses)))
          ..add(CompactSize.encode(Bytes.utf8Encode(terms)))
          ..add(description == null
              ? Uint8List(1)
              : CompactSize.encode(Bytes.utf8Encode(description!)))
          ..add(expiry == null
              ? Uint8List(1)
              : CompactSize.encode(Bytes.encodeBigInt(
                  BigInt.from(expiry!.millisecondsSinceEpoch ~/ 1000)))))
        .toBytes();
  }

  /// Construct a new [LicenseRecord] from binary data.
  ///
  /// See [serialize] for supported binary format.
  factory LicenseRecord.deserialize(Uint8List title, Uint8List serialized) =>
      LicenseRecord.decode(title, CompactSize.decode(serialized));

  /// Construct a new [LicenseRecord] from decoded binary data.
  ///
  /// See [serialize] for supported binary format.
  factory LicenseRecord.decode(Uint8List title, List<Uint8List> bytes) {
    List<LicenseUse> uses = jsonDecode(Bytes.utf8Decode(bytes[0]))
        .map<LicenseUse>((use) => LicenseUse.fromMap(use))
        .toList();
    return LicenseRecord(title, uses, Bytes.utf8Decode(bytes[1]),
        description: Bytes.utf8Decode(bytes[2]),
        expiry: DateTime.fromMillisecondsSinceEpoch(
            Bytes.decodeBigInt(bytes[3]).toInt() * 1000));
  }
}
