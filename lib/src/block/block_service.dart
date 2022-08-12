import '../transaction/transaction_model.dart';
import 'block_model.dart';

class BlockService {
  /// Creates a new block from a list of transactions.
  ///
  /// Calculates the Merkel Root from [TransactionModel] list
  Future<BlockModel> mint(List<TransactionModel> transactions) async {
    throw UnimplementedError();
  }
}
