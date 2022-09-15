import 'package:pointycastle/api.dart';

import '../../utils/bytes.dart';
import '../../utils/compact_size.dart' as compact_size;
import 'dart:typed_data';

import 'block_repository.dart';

/// The block model entity for local storage.
///
/// This model is used only for local operations. For blockchain operations the
/// serialized version of it is used.
class BlockModel {
  /// The unique identifier of this block.
  ///
  /// It is the SHA3-256 hash of the [header].
  Uint8List? id;

  /// The version number indicating the set of block validation rules to follow.
  late int version;

  /// The previous [BlockModel.id].
  ///
  /// It is SHA-3 hash of the previous block’s [header]. If this is the genesis
  /// block, the value is Uint8List(1);
  late Uint8List previousHash;

  /// The [MerkelTree.root] of the [TransactionModel] hashes taht are part of this.
  late Uint8List transactionRoot;

  /// The total number of [TransactionModel] that are part of this.
  late int transactionCount;

  /// The block creation timestamp.
  late final DateTime timestamp;

  /// Buils a new [BlockModel].
  ///
  /// If no [timestamp] is provided, it is considered a new [BlockModel] and
  /// the object creation time becomes the [timestamp].
  BlockModel({
    this.version = 1,
    required this.previousHash,
    required this.transactionRoot,
    required this.transactionCount,
    timestamp,
  }) {
    this.timestamp = timestamp ?? DateTime.now();
  }

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
  ///     BlockRepository.columnTransactionCount : int
  ///    }
  /// ```
  BlockModel.fromMap(Map<String, dynamic> map)
      : id = map[BlockRepository.columnId],
        version = map[BlockRepository.columnVersion],
        previousHash = map[BlockRepository.columnPreviousHash],
        transactionRoot = map[BlockRepository.columnTransactionRoot],
        transactionCount = map[BlockRepository.columnTransactionCount],
        timestamp = DateTime.fromMillisecondsSinceEpoch(
            map[BlockRepository.columnTimestamp] * 1000);

  /// Builds a [BlockModel] from a [serialized] list of bytes.
  ///
  /// Check [serialize] for more information on how the [serialized] is built.
  BlockModel.deserialize(Uint8List serialized) {
    List<Uint8List> extractedBlockBytes = compact_size.decode(serialized);
    version = decodeBigInt(extractedBlockBytes[0]).toInt();
    timestamp = DateTime.fromMillisecondsSinceEpoch(
        decodeBigInt(extractedBlockBytes[1]).toInt() * 1000);
    previousHash = extractedBlockBytes[2];
    transactionRoot = extractedBlockBytes[3];
    transactionCount = decodeBigInt(extractedBlockBytes[4]).toInt();
    if (extractedBlockBytes.sublist(5).length != transactionCount) {
      throw Exception(
          'Invalid transaction count. Expected $transactionCount. Got ${extractedBlockBytes.sublist(5).length}');
    }
    id = Digest("SHA3-256").process(header());
  }

  /// Creates a [Uint8List] representation of the block.
  ///
  /// The serialized [BlockModel] is created by combining in a [Uint8List] the
  /// [BlockModel.header] and the block [body], that is built from the
  /// [TransacionModel] list by [TransactionService.serializeTransactions].
  Uint8List serialize(Uint8List body) {
    Uint8List head = header();
    return (BytesBuilder()
          ..add(head)
          ..add(body))
        .toBytes();
  }

  /// Creates the [Uint8List] representation of the block header.
  ///
  /// The block header is represented by a [Uint8List] of the block properties.
  /// Each item is prepended by its size calculate with [compact_size.toSize].
  /// The Uint8List structure is:
  /// ```
  /// Uint8List<Uint8List> header = Uin8List.fromList([
  ///   ...compact_size.toSize(version),
  ///   ...version,
  ///   ...compact_size.toSize(timestamp),
  ///   ...timestamp,
  ///   ...compact_size.toSize(previousHash),
  ///   ...previousHash,
  ///   ...compact_size.toSize(transactionRoot),
  ///   ...transactionRoot,
  ///   ...compact_size.toSize(transactionCount),
  ///   ...transactionCount,
  /// ]);
  /// ```
  Uint8List header() {
    Uint8List serializedVersion = encodeBigInt(BigInt.from(version));
    Uint8List serializedTimestamp = (BytesBuilder()
          ..add(encodeBigInt(
              BigInt.from(timestamp.millisecondsSinceEpoch ~/ 1000))))
        .toBytes();
    Uint8List serializedPreviousHash = previousHash;
    Uint8List serializedTransactionRoot = transactionRoot;
    Uint8List serializedTransactionCount =
        encodeBigInt(BigInt.from(transactionCount));
    return (BytesBuilder()
          ..add(compact_size.toSize(serializedVersion))
          ..add(serializedVersion)
          ..add(compact_size.toSize(serializedTimestamp))
          ..add(serializedTimestamp)
          ..add(compact_size.toSize(serializedPreviousHash))
          ..add(serializedPreviousHash)
          ..add(compact_size.toSize(serializedTransactionRoot))
          ..add(serializedTransactionRoot)
          ..add(compact_size.toSize(serializedTransactionCount))
          ..add(serializedTransactionCount))
        .toBytes();
  }

  /// Overrides toString() method for useful error messages
  @override
  String toString() => '''BlockModel
      'id': $id,
      'version': $version,
      'previousHash': $previousHash,
      'transactionRoot': $transactionRoot,
      'transactionCount': $transactionCount,
      'timestamp': $timestamp
    ''';
}
