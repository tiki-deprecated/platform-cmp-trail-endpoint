/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

class KeystoreModel {
  late final String? address;
  late final String? chain;
  late final String? signKey;
  late final String? dataKey;

  KeystoreModel({this.address, this.chain, this.signKey, this.dataKey});

  KeystoreModel.fromJson(Map<String, dynamic>? json) {
    if (json != null) {
      address = json['address'];
      chain = json['chain'];
      signKey = json['sign_key'];
      dataKey = json['data_key'];
    }
  }

  Map<String, dynamic> toJson() => {
        'address': address,
        'chain': chain,
        'sign_key': signKey,
        'data_key': dataKey
      };

  @override
  String toString() {
    return 'KeyStoreModel{address: $address, chain: $chain, '
        'signKey: *****, dataKey: ***** }';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KeystoreModel &&
          runtimeType == other.runtimeType &&
          address == other.address &&
          chain == other.chain &&
          signKey == other.signKey &&
          dataKey == other.dataKey;

  @override
  int get hashCode =>
      address.hashCode ^ chain.hashCode ^ signKey.hashCode ^ dataKey.hashCode;
}
