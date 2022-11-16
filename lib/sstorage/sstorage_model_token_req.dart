/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

/// The model for requesting a token to write data to object storage
/// 
/// When a user wants to write to the object storage, an authentication token 
/// must be requested. To request the token, the user must provide the apiId 
/// that identifies the company that is writing that data in the object storage 
/// and proof of authorship, to make sure that whoever is writing to a specific 
/// address is holding the private key for that address. This can be done by
/// signing a generic string and sending with the request the signature, the 
/// public key, and the original string. With that information, the server can
/// verify the signature and make sure that the one trying to create a new 
/// registry in a specific address is the one that holds the private key for 
/// that address.
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
