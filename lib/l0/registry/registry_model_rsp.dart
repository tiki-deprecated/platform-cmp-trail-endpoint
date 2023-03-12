/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import '../../utils/rsa/rsa_private_key.dart';

class RegistryModelRsp {
  RsaPrivateKey? signKey;
  List<String>? addresses;

  RegistryModelRsp({this.signKey, this.addresses});

  RegistryModelRsp.fromMap(Map<String, dynamic>? map) {
    if (map != null) {
      if (map['signKey'] != null) {
        signKey = RsaPrivateKey.decode(map['signKey']);
      }
      addresses = map['addresses']?.map<String>((a) => a as String).toList();
    }
  }

  @override
  String toString() {
    return 'RegistryModelRsp{signKey: ${signKey?.public}, addresses: $addresses}';
  }
}
