/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:typed_data';

import 'xchain_repository.dart';

/// The model representing synced blocks.
class XChainModel {
  /// The raw src (key) where the block was fetch from
  final String src;

  /// The address for the block
  Uint8List? address;

  /// The block's unique identifier
  Uint8List? blockId;

  /// The date the block was fetched on.
  DateTime? fetchedOn;

  /// Construct a [XChainModel].
  XChainModel(String src, {this.address, this.blockId, this.fetchedOn})
      : src = src.toLowerCase();

  /// Builds a [XChainModel] from a [map].
  ///
  /// It is used mainly for retrieving data from [XChainRepository].
  XChainModel.fromMap(Map<String, dynamic> map)
      : src = (map[XChainRepository.columnSrc] as String).toLowerCase(),
        address = map[XChainRepository.columnAddress],
        blockId = map[XChainRepository.columnBlockId],
        fetchedOn = map[XChainRepository.columnFetchedOn] != null
            ? DateTime.fromMillisecondsSinceEpoch(
                map[XChainRepository.columnFetchedOn])
            : null;

  /// Builds a [Map] from this.
  ///
  /// It is used mainly for persisting data in [XChainRepository].
  Map toMap() => {
        XChainRepository.columnSrc: src.toLowerCase(),
        XChainRepository.columnAddress: address,
        XChainRepository.columnBlockId: blockId,
        XChainRepository.columnFetchedOn: fetchedOn?.millisecondsSinceEpoch
      };
}
