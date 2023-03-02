/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:typed_data';

import '../../utils/bytes.dart';
import '../../utils/compact_size.dart';
import 'license_repository.dart';
import 'license_use.dart';

class LicenseRecord {
  Uint8List title;
  List<LicenseUse> uses;
  String terms;
  String? description;
  Uint8List? transactionId;
  DateTime? expiry;

  LicenseRecord(this.title, this.uses, this.terms,
      {this.description, this.transactionId, this.expiry});

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

  Map toMap() => {
        LicenseRepository.columnTitle: title,
        LicenseRepository.columnUses: uses.map((use) => use.toMap()).toList(),
        LicenseRepository.columnTerms: terms,
        LicenseRepository.columnDescription: description,
        LicenseRepository.columnTransactionId: transactionId,
        LicenseRepository.columnExpiry: expiry?.millisecondsSinceEpoch
      };

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

  factory LicenseRecord.deserialize(Uint8List title, Uint8List serialized) =>
      LicenseRecord.decode(title, CompactSize.decode(serialized));

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
