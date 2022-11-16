/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:typed_data';

/// The model used in block uploads to L0Storage
class SStorageModelUpload {
  String? key;
  Uint8List? content;

  SStorageModelUpload({this.key, this.content});

  SStorageModelUpload.fromMap(Map<String, dynamic>? map) {
    if (map != null) {
      key = map['key'];
      if (map['block'] != null) content = base64Decode(map['block']);
    }
  }

  Map<String, dynamic> toMap() =>
      {'key': key, 'block': content != null ? base64Encode(content!) : null};

  @override
  String toString() {
    return 'SStorageModelUpload{key: $key, content: ${content != null ? base64Encode(content!) : null}';
  }
}
