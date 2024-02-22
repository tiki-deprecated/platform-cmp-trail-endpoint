/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';

import 'package:pointycastle/api.dart';

import 'utils/bytes.dart';

class Key {
  final String id;
  final String address;

  Key(this.id, this.address);

  Key.pem(this.id, String pem)
      : address = Bytes.base64UrlEncode(
            Digest("SHA3-256").process(base64.decode(pem)));
}
