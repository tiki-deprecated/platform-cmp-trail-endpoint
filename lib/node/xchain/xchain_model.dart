/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */
import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/api.dart';

import '../../utils/utils.dart';
import 'xchain_repository.dart';

/// {@category Node}
/// The model to store information about cross chain reference.
class XchainModel {
  /// The chain address. It is the SHA3-256 hash of the
  Uint8List address;

  /// The chain public key bytes.
  final CryptoRSAPublicKey publicKey;

  /// The id for the last validated block.
  Uint8List lastBlock;

  /// Builds a [XchainModel] from its [publicKey].
  ///
  /// The [address] is derived from the [publicKey] using the SHA3-256 hash.
  /// If the chain was not synced yet, [lastBlock] should be null.
  XchainModel(this.publicKey, {lastBlock})
      : address = Digest("SHA3-256").process(base64.decode(publicKey.encode())),
        lastBlock = lastBlock ?? Uint8List(1);

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
      publicKey : $publicKey,
      lastBlock : $lastBlock,
    ''';
  }
}
