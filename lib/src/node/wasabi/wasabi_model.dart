import 'dart:convert';

import 'wasabi_model_rsp.dart';

class WasabiModel {
  String? id;
  String? signature;
  DateTime? timestamp;
  String? payload;

  WasabiModel({
    required this.id,
    this.signature,
    this.timestamp,
    required this.payload,
  });

  WasabiModel.fromRsp(WasabiModelRsp response) {
    Map<String, dynamic> data = jsonDecode(response.payload ?? '{}');
    id = data['id'];
    signature = data['signature'];
    timestamp = data['timestamp'];
    payload = data['payload'];
  }
}
