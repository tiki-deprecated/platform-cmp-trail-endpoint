/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:typed_data';

import '../../utils/rsa/rsa_private_key.dart';

class KeysModel {
  final Uint8List address;
  final CryptoRSAPrivateKey privateKey;

  KeysModel(this.address, this.privateKey);

  KeysModel.fromMap(map)
      : address = base64Url.decode(map['address']!),
        privateKey = CryptoRSAPrivateKey.decode(map['private_key']!);

  Map<String, String> toMap() {
    return {
      'address': base64Url.encode(address),
      'private_key': privateKey.encode()
    };
  }
}
