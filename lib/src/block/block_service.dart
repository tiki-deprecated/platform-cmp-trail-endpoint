import '../transaction/transaction_model.dart';
import 'block_model.dart';

class BlockService {
  /// Creates a new block from a list of transactions.
  ///
  /// Calculates the Merkel Root from [TransactionModel] list
  Future<BlockModel> mint(List<TransactionModel> transactions) async {
    throw UnimplementedError();
  }

  /// Loads a block from the chain by its hash. If the id is provided, it loads
  /// by the id and check the hash for equality and integrity.
  Future<BlockModel> load(String hash, {int? id, String? chain}) async {
    throw UnimplementedError();
  }

  /// Validates the block hash.
  Future<bool> validate(BlockModel block) async {
    throw UnimplementedError();
  }

  /// Serializes the block to be included in the chain.
  String serialize(BlockModel block) {
    throw UnimplementedError();
  }
}
