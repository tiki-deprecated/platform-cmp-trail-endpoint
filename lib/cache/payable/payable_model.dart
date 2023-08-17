/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:typed_data';

import '../../license_record.dart';
import '../../payable_record.dart';
import '../../utils/bytes.dart';
import '../../utils/compact_size.dart';
import 'payable_repository.dart';

/// Describes a payable against a License Model [LicenseModel]
class PayableModel {
  /// The corresponding id of the license
  Uint8List license;

  /// The total amount. Can be a simple numeric value, or an atypical value
  /// such as downloadable content.
  String amount;

  /// Describes the type of payment (e.g. loyalty-point, cash, coupon, etc.)
  String type;

  /// The transaction id of this record.
  Uint8List? transactionId;

  /// The record timestamp
  DateTime? timestamp;

  /// A human-readable description of the payment.
  String? description;

  /// A customer-specific reference identifier
  String? reference;

  /// An expiration date for the payment
  DateTime? expiry;

  PayableModel(this.license, this.amount, this.type,
      {this.description,
      this.transactionId,
      this.expiry,
      this.reference,
      this.timestamp});

  /// Construct a [PayableModel] from a [map].
  ///
  /// Primary use is [PayableRepository] object marshalling.
  PayableModel.fromMap(Map<String, dynamic> map)
      : license = map[PayableRepository.columnLicense],
        amount = map[PayableRepository.columnAmount],
        type = map[PayableRepository.columnType],
        transactionId = map[PayableRepository.columnTransactionId],
        description = map[PayableRepository.columnDescription],
        timestamp = map[PayableRepository.timestamp] != null
            ? DateTime.fromMillisecondsSinceEpoch(
                map[PayableRepository.timestamp])
            : null,
        reference = map[PayableRepository.columnReference],
        expiry = map[PayableRepository.columnExpiry] != null
            ? DateTime.fromMillisecondsSinceEpoch(
                map[PayableRepository.columnExpiry])
            : null;

  /// Converts this to Map
  ///
  /// Primary use is [PayableRepository] object marshalling.
  Map toMap() => {
        PayableRepository.columnLicense: license,
        PayableRepository.columnAmount: amount,
        PayableRepository.columnType: type,
        PayableRepository.columnDescription: description,
        PayableRepository.columnReference: reference,
        PayableRepository.columnTransactionId: transactionId,
        PayableRepository.columnExpiry: expiry?.millisecondsSinceEpoch,
        PayableRepository.timestamp: timestamp?.millisecondsSinceEpoch
      };

  /// Serializes this to binary.
  ///
  /// Primary use is on-chain storage. The [transactionId] and [license] are not
  /// represented in the serialized output.
  Uint8List serialize() {
    return (BytesBuilder()
          ..add(CompactSize.encode(Bytes.utf8Encode(amount)))
          ..add(CompactSize.encode(Bytes.utf8Encode(type)))
          ..add(description == null
              ? Uint8List(1)
              : CompactSize.encode(Bytes.utf8Encode(description!)))
          ..add(expiry == null
              ? Uint8List(1)
              : CompactSize.encode(Bytes.encodeBigInt(
                  BigInt.from(expiry!.millisecondsSinceEpoch ~/ 1000))))
          ..add(reference == null
              ? Uint8List(1)
              : CompactSize.encode(Bytes.utf8Encode(reference!))))
        .toBytes();
  }

  /// Construct a new [PayableModel] from binary data.
  ///
  /// See [serialize] for supported binary format.
  factory PayableModel.deserialize(Uint8List license, Uint8List serialized,
          {DateTime? timestamp}) =>
      PayableModel.decode(license, CompactSize.decode(serialized),
          timestamp: timestamp);

  /// Construct a new [PayableModel] from decoded binary data.
  ///
  /// See [serialize] for supported binary format.
  factory PayableModel.decode(Uint8List license, List<Uint8List> bytes,
          {DateTime? timestamp}) =>
      PayableModel(
          license, Bytes.utf8Decode(bytes[0]), Bytes.utf8Decode(bytes[1]),
          description: Bytes.utf8Decode(bytes[2]),
          timestamp: timestamp,
          expiry: DateTime.fromMillisecondsSinceEpoch(
              Bytes.decodeBigInt(bytes[3]).toInt() * 1000),
          reference: Bytes.utf8Decode(bytes[4]));

  PayableRecord toRecord(LicenseRecord license) => PayableRecord(
      Bytes.base64UrlEncode(transactionId!), license, amount, type,
      description: description,
      reference: reference,
      expiry: expiry,
      timestamp: timestamp);
}
