import 'dart:typed_data';

import '../block/block_model.dart';

/// A transaction in the blockchain.
class TransactionModel {
  int? id;
  final int version;
  final String address;
  final Uint8List contents;
  final String assetRef;
  Uint8List? merkelProof;
  BlockModel? block;
  late final DateTime timestamp;
  late final String signature;

  TransactionModel({
    this.version = 1,
    required this.address,
    required this.contents,
    this.assetRef = '0x00',
  });

  TransactionModel.fromMap(Map<String, dynamic> map)
      : id = map['transaction_id'],
        version = map['version'],
        address = map['address'],
        contents = map['contents'],
        assetRef = map['assetRef'],
        merkelProof = map['merkel_proof'],
        block = map['block'],
        timestamp = map['timestamp'],
        signature = map['signature'];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'version': version,
      'address': address,
      'contents': contents,
      'asset_ref': assetRef,
      'merkel_proof': merkelProof,
      'block': block,
      'timestamp': timestamp,
      'signature': signature
    };
  }

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
  }
""";

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          // listEquals(contents, other.contents) &&
          // listEquals(merkelProof, other.merkelProof) &&
          signature == signature &&
          timestamp == other.timestamp;

  @override
  int get hashCode =>
      id.hashCode ^
      contents.hashCode ^
      merkelProof.hashCode ^
      signature.hashCode ^
      timestamp.hashCode;

  String toSqlValues() =>
      ''''$id', '$version', '$address', '$contents', '$assetRef', '$merkelProof', 
    '${block?.id}', '${timestamp.millisecondsSinceEpoch ~/ 1000}', '$signature''';
}
