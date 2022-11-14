/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

class SStorageModelTokenReq {
  String? pubKey;
  String? signature;
  String? stringToSign;

  SStorageModelTokenReq({this.pubKey, this.signature, this.stringToSign});

  SStorageModelTokenReq.fromMap(Map<String, dynamic>? map) {
    if (map != null) {
      pubKey = map['pubKey'];
      signature = map['signature'];
      stringToSign = map['stringToSign'];
    }
  }

  Map<String, dynamic> toMap() =>
      {'pubKey': pubKey, 'signature': signature, 'stringToSign': stringToSign};

  @override
  String toString() {
    return 'SStorageModelTokenReq{pubKey: $pubKey, signature: $signature, stringToSign: $stringToSign}';
  }
}
