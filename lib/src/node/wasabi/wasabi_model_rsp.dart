import 'dart:convert';

class WasabiModelRsp {
  int? code;
  String? status;
  String? message;
  String? payload;

  WasabiModelRsp.fromJson(String jsonStr) {
    Map jsonMap = jsonDecode(jsonStr);
    code = jsonMap['code'];
    status = jsonMap['status'];
    message = jsonMap['message'];
    payload = jsonMap['payload'];
  }
}
