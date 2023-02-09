/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

class StorageModelTokenReq {
  String? pubKey;
  String? signature;
  String? stringToSign;

  StorageModelTokenReq({this.pubKey, this.signature, this.stringToSign});

  StorageModelTokenReq.fromMap(Map<String, dynamic>? map) {
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
    return 'StorageModelTokenReq{pubKey: $pubKey, signature: $signature, stringToSign: $stringToSign}';
  }
}
