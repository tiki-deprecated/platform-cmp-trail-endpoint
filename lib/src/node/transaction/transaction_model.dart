import 'dart:typed_data';

import '../block/block_model.dart';

/// A transaction in the blockchain.
class TransactionModel {
  int? seq;
  String? id;
  final int version;
  final String address;
  final Uint8List contents;
  final String assetRef;
  Uint8List? merkelProof;
  BlockModel? block;
  late final DateTime timestamp;
  late final String signature;

  TransactionModel(
      {this.seq,
      this.id,
      this.version = 1,
      required this.address,
      required this.contents,
      this.assetRef = '0x00',
      this.merkelProof,
      this.block,
      timestamp}) {
    this.timestamp = timestamp ?? DateTime.now();
  }

  TransactionModel.fromMap(Map<String, dynamic> map)
      : seq = map['seq'],
        id = map['id'],
        version = map['version'],
        address = map['address'],
        contents = map['contents'],
        assetRef = map['assetRef'],
        merkelProof = map['merkel_proof'],
        block = map['block'],
        timestamp = map['timestamp'],
        signature = map['signature'];

  @override
  String toString() => """TransactionModel{
      'id': $id,
      'version': $version,
      'address': $address,
      'contents': $address,
      'asset_ref': assetRef,
      'merkel_proof': $merkelProof,
      'block': $block,
      'timestamp': $timestamp,
      'signature': $signature
    }
  }""";

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
