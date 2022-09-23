import 'dart:typed_data';

import 'package:pointycastle/pointycastle.dart';
import 'package:tiki_sdk_dart/node/node_service.dart';
import 'package:tiki_sdk_dart/utils/rsa/rsa.dart';

TransactionModel generateTransactionModel(int index, KeyModel key) {
  TransactionModel txn = TransactionModel(
      address: key.address,
      timestamp: DateTime.now(),
      contents: Uint8List.fromList([index]),
      version: 1,
      assetRef: 'AA==');
  txn.signature =
      UtilsRsa.sign(key.privateKey, txn.serialize(includeSignature: false));
  txn.id = Digest("SHA3-256").process(txn.serialize());
  return txn;
}
