import '../transaction/transaction_model.dart';

class BlockModelBody {
  final List<TransactionModel> transactions;

  BlockModelBody(this.transactions);
}
