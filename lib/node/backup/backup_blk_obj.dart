import 'dart:typed_data';

import '../../utils/utils.dart';
import '../node_service.dart';

class BackupBlkObj {
  late Uint8List signature;
  BlockModel block;
  List<TransactionModel> transactions;

  BackupBlkObj(this.block, this.transactions);

  BackupBlkObj.deserialize(Uint8List serializedBackup)
      : signature = serializedBackup.sublist(0, 33),
        block = BlockModel.deserialize(serializedBackup.sublist(33)),
        transactions = TransactionService.deserializeTransactions(
            serializedBackup.sublist(33));

  Uint8List serialize(KeysModel keys) {
    Uint8List body =
        TransactionService.staticTransactionsSerializer(transactions);
    Uint8List serializedBlock = block.serialize(body);
    signature = UtilsRsa.sign(keys.privateKey, serializedBlock);
    return (BytesBuilder()
          ..add(signature)
          ..add(block.serialize(body)))
        .toBytes();
  }
}
