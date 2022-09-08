import 'dart:typed_data';

import 'package:pointycastle/pointycastle.dart';
import 'package:tiki_sdk_dart/src/node/keys/keys_model.dart';
import 'package:tiki_sdk_dart/src/node/transaction/transaction_model.dart';
import 'package:tiki_sdk_dart/src/utils/rsa/rsa.dart';

TransactionModel generateTransactionModel(int index, KeysModel keys) {
  TransactionModel txn = TransactionModel(
      address: keys.address,
      timestamp: DateTime.now(),
      contents: Uint8List.fromList([index]),
      version: 1,
      assetRef: 'AA==');
  txn.signature = sign(keys.privateKey, txn.serialize(includeSignature: false));
  txn.id = Digest("SHA3-256").process(txn.serialize());
  return txn;
}
