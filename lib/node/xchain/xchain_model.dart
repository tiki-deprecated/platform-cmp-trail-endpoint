/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:typed_data';

import 'xchain_repository.dart';

class XChainModel {
  final String src;
  Uint8List? address;
  Uint8List? blockId;
  DateTime? fetchedOn;

  XChainModel(String src, {this.address, this.blockId, this.fetchedOn})
      : src = src.toLowerCase();

  XChainModel.fromMap(Map<String, dynamic> map)
      : src = (map[XChainRepository.columnSrc] as String).toLowerCase(),
        address = map[XChainRepository.columnAddress],
        blockId = map[XChainRepository.columnBlockId],
        fetchedOn = map[XChainRepository.columnFetchedOn] != null
            ? DateTime.fromMillisecondsSinceEpoch(
                map[XChainRepository.columnFetchedOn])
            : null;

  Map toMap() => {
        XChainRepository.columnSrc: src.toLowerCase(),
        XChainRepository.columnAddress: address,
        XChainRepository.columnBlockId: blockId,
        XChainRepository.columnFetchedOn: fetchedOn?.millisecondsSinceEpoch
      };
}
