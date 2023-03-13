/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:typed_data';

import '../../utils/rsa/rsa_private_key.dart';

/// The keys storage model.
class KeyModel {
  final String id;
  final Uint8List address;
  final RsaPrivateKey privateKey;

  KeyModel(this.id, this.address, this.privateKey);

  KeyModel.fromJson(this.id, String jsonString)
      : address = base64.decode(json.decode(jsonString)['address']!),
        privateKey =
            RsaPrivateKey.decode(jsonDecode(jsonString)['private_key']!);

  String toJson() {
    return jsonEncode({
      'address': base64.encode(address),
      'private_key': privateKey.encode()
    });
  }
}
