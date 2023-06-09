/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:typed_data';

import '../../payable_record.dart';
import '../../receipt_record.dart';
import '../../utils/bytes.dart';
import '../../utils/compact_size.dart';
import 'receipt_repository.dart';

/// Describes a payable against a License Model [LicenseModel]
class ReceiptModel {
  /// The corresponding id of the payable
  Uint8List payable;

  /// The amount paid out
  String amount;

  /// The transaction id of this record.
  Uint8List? transactionId;

  /// A human-readable description of the receipt.
  String? description;

  /// A customer-specific reference identifier
  String? reference;

  ReceiptModel(this.payable, this.amount,
      {this.description, this.transactionId, this.reference});

  /// Construct a [PayableModel] from a [map].
  ///
  /// Primary use is [PayableRepository] object marshalling.
  ReceiptModel.fromMap(Map<String, dynamic> map)
      : payable = map[ReceiptRepository.columnPayable],
        amount = map[ReceiptRepository.columnAmount],
        transactionId = map[ReceiptRepository.columnTransactionId],
        description = map[ReceiptRepository.columnDescription],
        reference = map[ReceiptRepository.columnReference];

  /// Converts this to Map
  ///
  /// Primary use is [PayableRepository] object marshalling.
  Map toMap() => {
        ReceiptRepository.columnPayable: payable,
        ReceiptRepository.columnAmount: amount,
        ReceiptRepository.columnDescription: description,
        ReceiptRepository.columnReference: reference,
        ReceiptRepository.columnTransactionId: transactionId,
      };

  /// Serializes this to binary.
  ///
  /// Primary use is on-chain storage. The [transactionId] and [license] are not
  /// represented in the serialized output.
  Uint8List serialize() {
    return (BytesBuilder()
          ..add(CompactSize.encode(Bytes.utf8Encode(amount)))
          ..add(description == null
              ? Uint8List(1)
              : CompactSize.encode(Bytes.utf8Encode(description!)))
          ..add(reference == null
              ? Uint8List(1)
              : CompactSize.encode(Bytes.utf8Encode(reference!))))
        .toBytes();
  }

  /// Construct a new [PayableModel] from binary data.
  ///
  /// See [serialize] for supported binary format.
  factory ReceiptModel.deserialize(Uint8List payable, Uint8List serialized) =>
      ReceiptModel.decode(payable, CompactSize.decode(serialized));

  /// Construct a new [PayableModel] from decoded binary data.
  ///
  /// See [serialize] for supported binary format.
  factory ReceiptModel.decode(Uint8List payable, List<Uint8List> bytes) =>
      ReceiptModel(payable, Bytes.utf8Decode(bytes[0]),
          description: Bytes.utf8Decode(bytes[1]),
          reference: Bytes.utf8Decode(bytes[2]));

  ReceiptRecord toRecord(PayableRecord payable) =>
      ReceiptRecord(Bytes.base64UrlEncode(transactionId!), payable, amount,
          description: description, reference: reference);
}
