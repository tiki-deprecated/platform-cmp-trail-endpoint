/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */
/// {@category Node}
import 'dart:convert';
import 'dart:typed_data';

import '../../utils/rsa/rsa_private_key.dart';

/// The keys storage model.
class KeysModel {
  final Uint8List address;
  final CryptoRSAPrivateKey privateKey;

  KeysModel(this.address, this.privateKey);

  KeysModel.fromJson(String jsonString)
      : address = base64.decode(json.decode(jsonString)['address']!),
        privateKey =
            CryptoRSAPrivateKey.decode(jsonDecode(jsonString)['private_key']!);

  String toJson() {
    return jsonEncode({
      'address': base64.encode(address),
      'private_key': privateKey.encode()
    });
  }
}
