/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:typed_data';

import 'package:pointycastle/api.dart';

import '../../utils/bytes.dart';
import '../../utils/compact_size.dart';
import 'block_repository.dart';

/// The block model entity for local storage.
///
/// This model is used only for local operations. For blockchain operations the
/// serialized version of it is used.
class BlockModel {
  /// The unique identifier of this block.
  ///
  /// It is the SHA3-256 hash of the Block header.
  Uint8List? id;

  /// The version number indicating the set of block validation rules to follow.
  late int version;

  /// The previous [BlockModel.id].
  ///
  /// It is SHA-3 hash of the previous block’s header. For the genesis
  /// block the value is Uint8List(1);
  late Uint8List previousHash;

  /// The [MerkelTree.root] of the transaction hashes that are part of this.
  late Uint8List transactionRoot;

  /// The block creation timestamp.
  late final DateTime timestamp;

  /// Buils a new [BlockModel].
  ///
  /// If no [timestamp] is provided, it is considered a new [BlockModel] and
  /// the object creation time becomes the [timestamp].
  BlockModel({
    this.id,
    this.version = 1,
    required this.previousHash,
    required this.transactionRoot,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Builds a [BlockModel] from a [map].
  ///
  /// It is used mainly for retrieving data from [BlockRepository].
  /// The map strucure is
  /// ```
  ///   Map<String, dynamic> map = {
  ///     BlockRepository.columnId : Uint8List
  ///     BlockRepository.columnVersion : int
  ///     BlockRepository.columnPreviousHash : Uint8List
  ///     BlockRepository.columnTransactionRoot : Uint8List
  ///     BlockRepository.columnTimestamp : int // Milliseconds since epoch
  ///    }
  /// ```
  BlockModel.fromMap(Map<String, dynamic> map)
      : id = map[BlockRepository.columnId],
        version = map[BlockRepository.columnVersion],
        previousHash = map[BlockRepository.columnPreviousHash],
        transactionRoot = map[BlockRepository.columnTransactionRoot],
        timestamp = DateTime.fromMillisecondsSinceEpoch(
            map[BlockRepository.columnTimestamp]);

  /// Builds a [BlockModel] from a [block] list of bytes.
  ///
  /// Check [serialize] for more information on how the [block] is built.
  BlockModel.deserialize(Uint8List block) {
    List<Uint8List> extractedBlockBytes = CompactSize.decode(block);
    version = Bytes.decodeBigInt(extractedBlockBytes[0]).toInt();
    timestamp = DateTime.fromMillisecondsSinceEpoch(
        Bytes.decodeBigInt(extractedBlockBytes[1]).toInt() * 1000);
    previousHash = extractedBlockBytes[2];
    transactionRoot = extractedBlockBytes[3];
    id = Digest("SHA3-256").process(serialize());
  }

  /// Creates the [Uint8List] representation of the block header.
  ///
  /// The block header is represented by a [Uint8List] of the block properties.
  /// Each item is prepended by its size calculate with [CompactSize.encode].
  /// The Uint8List structure is:
  /// ```
  /// Uint8List<Uint8List> header = (BytesBuilder()
  ///   ..add(UtilsCompactSize.encode(version))),
  ///   ..add(UtilsCompactSize.encode(timestamp)),
  ///   ..add(UtilsCompactSize.encode(previousHash)),
  ///   ..add(UtilsCompactSize.encode(transactionRoot)),
  /// ]);
  /// ```
  Uint8List serialize() {
    Uint8List serializedVersion = Bytes.encodeBigInt(BigInt.from(version));
    Uint8List serializedTimestamp = (BytesBuilder()
          ..add(Bytes.encodeBigInt(
              BigInt.from(timestamp.millisecondsSinceEpoch ~/ 1000))))
        .toBytes();
    Uint8List serializedPreviousHash = previousHash;
    Uint8List serializedTransactionRoot = transactionRoot;

    return (BytesBuilder()
          ..add(CompactSize.encode(serializedVersion))
          ..add(CompactSize.encode(serializedTimestamp))
          ..add(CompactSize.encode(serializedPreviousHash))
          ..add(CompactSize.encode(serializedTransactionRoot)))
        .toBytes();
  }

  /// Overrides toString() method for useful error messages
  @override
  String toString() => '''
      BlockModel - 
      'id': $id,
      'version': $version,
      'previousHash': $previousHash,
      'transactionRoot': $transactionRoot,
      'timestamp': $timestamp
    ''';
}
