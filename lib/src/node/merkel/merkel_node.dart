import 'dart:typed_data';

import '../transaction/transaction_model.dart';

class MerkelNode {
  List<TransactionModel> includedTransactions = [];
  int? level;
  int? order;
  Uint8List? hash;
}
