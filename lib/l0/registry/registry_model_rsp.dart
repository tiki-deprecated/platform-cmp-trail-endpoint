/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import '../../utils/rsa/rsa_private_key.dart';

/// A Registry Response
///
/// A POJO style model representing a JSON object for
/// the registry service.
class RegistryModelRsp {
  /// A [signKey] unique to the registered id for use in
  /// in generating app signatures.
  RsaPrivateKey? signKey;

  /// All [addresses] corresponding to the registered id
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
