/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

/// A L0 Storage Policy Request Model
class L0StorageModelPolicyReq {
  String? pubKey;
  String? signature;
  String? stringToSign;

  L0StorageModelPolicyReq({this.pubKey, this.signature, this.stringToSign});

  L0StorageModelPolicyReq.fromMap(Map<String, dynamic>? map) {
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
    return 'L0StorageModelPolicyReq{pubKey: $pubKey, signature: $signature, stringToSign: $stringToSign}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is L0StorageModelPolicyReq &&
          runtimeType == other.runtimeType &&
          pubKey == other.pubKey &&
          signature == other.signature &&
          stringToSign == other.stringToSign;

  @override
  int get hashCode =>
      pubKey.hashCode ^ signature.hashCode ^ stringToSign.hashCode;
}
