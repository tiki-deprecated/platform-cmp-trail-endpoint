import 'dart:convert';
import 'dart:typed_data';

/// A transaction in the blockchain.
class TransactionModel {
  /// The unique ID number for the transaction. It is defined in the database
  /// and is global for all transactions in all blocks. It is intended for
  /// internal use. Should not be serialized.
  late final int id;

  /// The number indicating the set of transaction validation rules to follow.
  final int version;

  /// The SHA-3 hash of the public key used for transaction signature.
  final String address;

  /// The binary encoded transaction payload.
  ///
  /// Format: `[content schema byte length][content schema ID][payload]`
  /// There is no max contents size, but contents are encouraged to stay under
  /// 100kB for performance.
  final Uint8List? contents;

  /// The URI pointer to the original asset mint transaction. `0x00` for mint
  /// transactions.
  ///
  /// Example: chain_id://address/transaction_id
  /// Where transaction_id is the SHA-3 hash of the original mint transaction
  final String? assetRef;

  /// The transaction creation time represented in seconds since epoch.
  final int timestamp;

  /// The hash of the block in which the transaction was included.
  late final String blockHash;

  /// The minimum path to validate the transaction by rebuilding the transaction
  /// root for the Merkel Tree. 
  /// 
  /// It is composed by a Map where the key is the level and the value is
  /// a list of hashes that should be used to build the hash for that level.
  /// Each list should be hashed in pairs until there is only one hash left of hashes that should be used as the leafs of 
  /// the Merkel Tree. The hashes should be stored in correct order, where each pair 
  late final List<Uint16List> merkelProof;

  /// The asymmetric digital signature (RSA) for the entire transaction,
  /// including the contents.
  late final Uint8List signature;

  TransactionModel({
    required this.version, 
    required this.address, 
    required this.timestamp, 
    required this.signature, 
    this.assetRef,
    this.contents});

  TransactionModel.fromMap(Map<String, dynamic> map)
      : version = map['version'],
        address = map['address']!,
        timestamp = map['timestamp']!,
        assetRef = map['asset_ref']!,
        signature = map['signature']!,
        merkelProof = jsonDecode(map['merkelProof']),
        contents = Uint8List.fromList(jsonDecode(map['contents']));

  Map<String, dynamic> toMap() {
    return {
      'id' : id,
      'version' : version,
      'address' : address,
      'timestamp': timestamp,
      'asset_reference' : assetRef,
      'signature' : jsonEncode(signature),
      'merkel_proof' : jsonEncode(merkelProof),
      'contents' : jsonEncode(contents),
      'block_hash' : blockHash
    };
  }

}
