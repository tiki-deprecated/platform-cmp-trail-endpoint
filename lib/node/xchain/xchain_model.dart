/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */
import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/api.dart';

import 'xchain_repository.dart';

/// {@category Node}
/// The model to store information about cross chain reference.
class XchainModel {
  /// The base64Url representation of the chain address.
  String address;

  /// The chain public key bytes.
  Uint8List publicKey;

  /// The id for the last validated block.
  Uint8List? lastBlock;

  /// Builds a [XchainModel] from its [publicKey].
  /// 
  /// The [address] is derived from the [publicKey] using the SHA3-256 hash.
  /// If the chain was not synced yet, [lastBlock] should be null.
  XchainModel(this.publicKey, {this.lastBlock})
      : address = base64.encode(Digest("SHA3-256").process(publicKey));

  /// Builds a [XchainModel] from a [map].
  ///
  /// It is used mainly for retrieving data from [XchainRepository].
  /// The map strucure is
  /// ```
  ///   Map<String, dynamic> map = {
  ///     XchainRepository.columnAddress : String,
  ///     XchainRepository.columnPublicKey : Uint8List
  ///     XchainRepository.columnLastBlock : Uint8List?
  ///    }
  /// ```
  XchainModel.fromMap(Map<String, dynamic> map)
      : address = map[XchainRepository.columnAddress],
        publicKey = map[XchainRepository.columnPublicKey],
        lastBlock = map[XchainRepository.columnLastBlock];

  /// Overrides toString() method for useful error messages
  @override
  String toString() {
    return '''XchainModel
      address : $address,
      publicKey : ${base64.encode(publicKey)},
      lastBlock : ${lastBlock == null ? 'null' : base64.encode(lastBlock!)},
    ''';
  }
}
