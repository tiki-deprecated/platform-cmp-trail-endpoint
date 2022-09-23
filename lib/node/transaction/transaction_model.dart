/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */
/// {@category Node}
import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/api.dart';

import '../../utils/utils.dart';
import '../block/block_model.dart';
import 'transaction_repository.dart';

/// A transaction in the blockchain.
class TransactionModel {
  /// The version number indicating the set of validation rules to follow.
  late final int version;

  /// The SHA-3 hash of the public key used for signature.
  late final Uint8List address;

  /// The timestamp of the creation of this.
  late final DateTime timestamp;

  /// The path of the asset to which this refers to. AA== if null.
  late final String assetRef;

  /// The binary encoded transaction payload.
  ///
  /// There is no max contents size, but contents are encouraged to stay under
  /// 100kB for performance.
  late final Uint8List contents;

  /// The SHA-3 256 hash of the [serialize] Uint8List.
  ///
  /// Should include signature.
  Uint8List? id;

  /// The list of hashes that is used in [MerkelTree.validate] to verify that
  /// this [TransactionModel] is included in [block].
  Uint8List? merkelProof;

  /// The [BlockModel] in which this [TransactionModel] is included.
  BlockModel? block;

  /// The asymmetric digital signature (RSA) for the [serialize] transaction.
  Uint8List? signature;

  String get path => "${base64Url.encode(address)}/${base64Url.encode(block!.id!)}/${base64Url.encode(id!)}";

  /// Builds a new [TransactionModel]
  ///
  /// If no [timestamp] is provided, the object creation time is used.
  /// If no [assetRef] is provided, it uses AA== as [assetRef] value.
  TransactionModel(
      {this.id,
      this.version = 1,
      required this.address,
      required this.contents,
      this.assetRef = "AA==",
      DateTime? timestamp,
      this.merkelProof,
      this.block,
      this.signature})
      : timestamp = timestamp ?? DateTime.fromMillisecondsSinceEpoch((DateTime.now().millisecondsSinceEpoch ~/1000) * 1000);

  /// Builds a [BlockModel] from a [map].
  ///
  /// It is used mainly for retrieving data from [BlockRepository].
  /// The map strucure is
  /// ```
  ///   Map<String, dynamic> map = {
  ///     TransactionRepository.columnId : String,
  ///     TransactionRepository.columnVersion : int,
  ///     TransactionRepository.columnAddress : Uint8List,
  ///     TransactionRepository.columnContents : Uint8List,
  ///     TransactionRepository.columnAssetRef : String,
  ///     TransactionRepository.columnMerkelProof : Uint8List,
  ///     TransactionRepository.columnTimestamp : int, // seconds since epoch
  ///     TransactionRepository.columnSignature : Uint8List,
  ///    }
  /// ```
  TransactionModel.fromMap(Map<String, dynamic> map)
      : id = map[TransactionRepository.columnId],
        version = map[TransactionRepository.columnVersion],
        address = map[TransactionRepository.columnAddress],
        contents = map[TransactionRepository.columnContents],
        assetRef = map[TransactionRepository.columnAssetRef],
        merkelProof = map[TransactionRepository.columnMerkelProof],
        block = map['block'],
        timestamp = DateTime.fromMillisecondsSinceEpoch(
            map[TransactionRepository.columnTimestamp]),
        signature = map[TransactionRepository.columnSignature];

  /// Builds a [TransactionModel] from a [transaction] list of bytes.
  ///
  /// Check [serialize] for more information on how the [transaction] is built.
  TransactionModel.deserialize(Uint8List transaction) {
    List<Uint8List> extractedBytes = UtilsCompactSize.decode(transaction);
    version = UtilsBytes.decodeBigInt(extractedBytes[0]).toInt();
    address = extractedBytes[1];
    timestamp = DateTime.fromMillisecondsSinceEpoch(
        UtilsBytes.decodeBigInt(extractedBytes[2]).toInt() * 1000);
    assetRef = base64.encode(extractedBytes[3]);
    signature = extractedBytes[4];
    contents = extractedBytes[5];
    id = Digest("SHA3-256").process(serialize());
  }

  /// Creates a [Uint8List] representation of this.
  ///
  /// The Uint8List is built by a list of the transaction properties, prepended
  /// by its size obtained from [UtilsCompactSize.toSize].
  /// Use with [includeSignature] to false, to sign and verify the signature.
  ///
  /// ```
  /// Uint8List serialized = Uint8List.fromList([
  ///   ...UtilsCompactSize.toSize(version),
  ///   ...version,
  ///   ...UtilsCompactSize.toSize(address),
  ///   ...address,
  ///   ...UtilsCompactSize.toSize(timestamp),
  ///   ...timestamp,
  ///   ...UtilsCompactSize.toSize(assetRef),
  ///   ...assetRef,
  ///   ...UtilsCompactSize.toSize(signature),
  ///   ...signature,
  ///   ...UtilsCompactSize.toSize(contents),
  ///   ...contents,
  /// ]);
  /// ```
  Uint8List serialize({includeSignature = true}) {
    Uint8List versionBytes = UtilsBytes.encodeBigInt(BigInt.from(version));
    Uint8List serializedVersion = (BytesBuilder()
          ..add(UtilsCompactSize.toSize(versionBytes))
          ..add(versionBytes))
        .toBytes();
    Uint8List serializedAddress = (BytesBuilder()
          ..add(UtilsCompactSize.toSize(address))
          ..add(address))
        .toBytes();
    Uint8List timestampBytes = UtilsBytes.encodeBigInt(
        BigInt.from(timestamp.millisecondsSinceEpoch ~/ 1000));
    Uint8List serializedTimestamp = (BytesBuilder()
          ..add(UtilsCompactSize.toSize(timestampBytes))
          ..add(timestampBytes))
        .toBytes();
    Uint8List assetRefBytes = base64.decode(assetRef);
    Uint8List serializedAssetRef = (BytesBuilder()
          ..add(UtilsCompactSize.toSize(assetRefBytes))
          ..add(assetRefBytes))
        .toBytes();
    Uint8List serializedSignature = (BytesBuilder()
          ..add(UtilsCompactSize.toSize(includeSignature && signature != null
              ? signature!
              : Uint8List(0)))
          ..add(includeSignature && signature != null
              ? signature!
              : Uint8List(0)))
        .toBytes();
    Uint8List serializedContents = (BytesBuilder()
          ..add(UtilsCompactSize.toSize(contents))
          ..add(contents))
        .toBytes();
    return (BytesBuilder()
          ..add(serializedVersion)
          ..add(serializedAddress)
          ..add(serializedTimestamp)
          ..add(serializedAssetRef)
          ..add(serializedSignature)
          ..add(serializedContents))
        .toBytes();
  }

  /// Overrides [==] operator to use [id] as the diferentiation parameter.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  /// Overrides toString() method for useful error messages
  @override
  String toString() => ''''
      TransactionModel - 
      id : $id,
      version : $version,
      address : $address,
      asset_ref : $assetRef,
      block : ${block?.id ?? 'null'},
      timestamp : $timestamp,
      signature : $signature
    ''';
}
