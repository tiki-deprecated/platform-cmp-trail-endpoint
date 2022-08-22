/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import '../../utils/rsa/rsa_private_key.dart';

class KeysModel {
  late final String address;
  late final CryptoRSAPrivateKey privateKey;

  static fromMap(jsonDecode) {}

  Object? toMap() {}
}
