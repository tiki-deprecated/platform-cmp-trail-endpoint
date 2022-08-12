class BlockModelHeader {
  /// The number indicating the set of transaction validation rules to follow.
  static const int ver = 1;

  /// The transaction creation time represented in seconds since epoch.
  final int timestamp;

  /// The SHA-3 hash of the previous block’s header.
  final String previousHash;

  /// The Merkle root derived from all the SHA-3 hashes of all the transactions in the block.
  final String transactionRoot;

  BlockModelHeader(
    this.timestamp,
     this.previousHash, 
     this.transactionRoot);
}
