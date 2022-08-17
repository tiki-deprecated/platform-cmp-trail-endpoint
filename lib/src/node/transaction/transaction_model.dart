import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/pointycastle.dart';

/// A transaction in the blockchain.
class TransactionModel {
  int transactionId
  int version
  String address
  Uint8List contents
  String assetRef
  Uint8List merkelProof
  BlockModel block
  DateTime timestamp
  String signature

}
