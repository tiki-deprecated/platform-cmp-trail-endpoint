class BlockModel {
  /// The unique ID number for the transaction. It is defined in the database
  /// and is global for all transactions in all blocks. It is intended for
  /// internal use. Should not be serialized.
  late final int id;

  /// The number indicating the set of transaction validation rules to follow.
  final int version;

  /// The transaction creation time represented in seconds since epoch.
  final int timestamp;

  /// The SHA-3 hash of the previous block’s header.
  final String previousHash;

  /// The Merkle root derived from all the SHA-3 hashes of all the transactions
  /// in the block.
  final String transactionRoot;

  /// The total number of transactions bundled in the block.
  final int transationCount;

  BlockModel(
      {this.version = 1,
      required this.previousHash,
      required this.transactionRoot,
      required this.transationCount})
      : timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

  BlockModel.fromMap(Map<String, dynamic> map)
      : version = map['version'],
        previousHash = map['previousHash'],
        transactionRoot = map['transactionRoot'],
        transationCount = map['transationCount'],
        timestamp = map['timestamp'];

  Map<String, dynamic> toMap() {
    return {
      'version' : version,
      'previousHash' : previousHash,
      'transactionRoot' : transactionRoot,
      'transationCount' : transationCount,
      'timestamp' : timestamp,
    };
  }
}
