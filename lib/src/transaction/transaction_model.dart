import 'dart:typed_data';

/// A transaction in the blockchain.
class TransactionModel{

  /// The number indicating the set of transaction validation rules to follow.
  final int ver;
  
  /// The SHA-3 hash of the public key used for transaction signature.
  final String address;
  
  /// The transaction creation time represented in seconds since epoch.
  final int timestamp;

  /// The URI pointer to the original asset mint transaction. `0x00` for mint
  /// transactions.
  /// 
  /// Example: chain_id://address/transaction_id 
  /// Where transaction_id is the SHA-3 hash of the original mint transaction
  final String assetRef;
 
  /// The asymmetric digital signature (RSA) for the entire transaction, 
  /// including the contents.
  final String signature;
  
  /// The binary encoded transaction payload. 
  /// 
  /// Format: `[content schema byte length][content schema ID][payload]`
  /// There is no max contents size, but contents are encouraged to stay under 
  /// 100kB for performance.
  final Uint8List? contents;

  TransactionModel(
    this.ver,
    this.address, 
    this.timestamp, 
    this.assetRef, 
    this.signature, 
    this.contents);

  TransactionModel.fromMap(Map<String,dynamic> map) :
    ver = map['ver'],
    address = map['address']!,
    timestamp = map['timestamp']!,
    assetRef = map['asset_ref']!,
    signature = map['signature']!,
    contents = Uint8List.fromList(map['contents']);

  Map<String, dynamic> toMap(){
    return {
    'address' : address, 
    'timestamp' : timestamp, 
    'assetRef' : assetRef, 
    'signature' : signature, 
    'contents' : contents};
  }
}