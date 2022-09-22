/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */
/// @nodoc
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

  /// Overrides toString() method for useful error messages
  @override
  String toString() {
    return 'L0StorageModelPolicyReq{pubKey: $pubKey, signature: $signature, stringToSign: $stringToSign}';
  }
}
