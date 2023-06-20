/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';

import 'bytes.dart';

/// The Merkel Tree representation.
class MerkelTree {
  /// The list of Merkel Proofs for each hash in [hashes].
  Map<Uint8List, Uint8List> proofs = {};

  /// The list of hashes that are used to build this Merkel Tree.
  final List<Uint8List> hashes;

  /// The merkel root.
  late final Uint8List? root;

  int depth = 1;

  /// Builds this Merkel Tree from a list of hashes.
  MerkelTree.build(this.hashes) {
    if (hashes.length == 1) {
      Uint8List hash = hashes.single;
      proofs[hash] = (BytesBuilder()
            ..addByte(1)
            ..add(hash))
          .toBytes();
      root = Digest("SHA3-256").process((BytesBuilder()
            ..add(hash)
            ..add(hash))
          .toBytes());
      depth = 1;
    } else {
      root = _calculate([...hashes]);
    }
  }

  /// Validates the inclusion of the [hash] in [root] by rebuilding it using [proof]
  static bool validate(Uint8List hash, Uint8List proof, Uint8List root) {
    int pos = proof[0];
    Uint8List hashPair = proof.sublist(1, 33);
    if (pos == 0) {
      hash = Digest("SHA3-256").process((BytesBuilder()
            ..add(hashPair)
            ..add(hash))
          .toBytes());
    } else {
      hash = Digest("SHA3-256").process((BytesBuilder()
            ..add(hash)
            ..add(hashPair))
          .toBytes());
    }
    if (proof.length > 33) return validate(hash, proof.sublist(33), root);
    return Bytes.memEquals(hash, root);
  }

  Uint8List _calculate(List<Uint8List> inputHashes) {
    List<Uint8List> outputHashes = [];
    if (inputHashes.length % 2 == 1) {
      inputHashes.add(inputHashes.last);
    }
    for (int i = 0; i < inputHashes.length; i = i + 2) {
      Uint8List? leftHash = inputHashes[i];
      Uint8List? rightHash = inputHashes[i + 1];
      Uint8List hash = Digest("SHA3-256").process((BytesBuilder()
            ..add(leftHash)
            ..add(rightHash))
          .toBytes());
      outputHashes.add(hash);
    }

    _calculateProof(outputHashes, inputHashes);

    if (outputHashes.length > 1) {
      depth++;
      return _calculate(outputHashes);
    }

    return outputHashes.single;
  }

  void _calculateProof(
      List<Uint8List> outputHashes, List<Uint8List> inputHashes) {
    int hashesPerOutput = pow(2, depth).toInt();
    for (int i = 0; i < outputHashes.length; i++) {
      Uint8List? leftHash = inputHashes[i * 2];
      Uint8List? rightHash = inputHashes[(i * 2) + 1];
      for (int j = 0; j < hashesPerOutput; j++) {
        int index = j + (i * hashesPerOutput);
        if (index == hashes.length) break;
        Uint8List hash = hashes[index];
        if (j < hashesPerOutput / 2) {
          proofs[hash] = (BytesBuilder()
                ..add(proofs[hash] ?? List.empty())
                ..addByte(1)
                ..add(rightHash))
              .toBytes();
        } else {
          proofs[hash] = (BytesBuilder()
                ..add(proofs[hash] ?? List.empty())
                ..addByte(0)
                ..add(leftHash))
              .toBytes();
        }
      }
    }
  }
}
