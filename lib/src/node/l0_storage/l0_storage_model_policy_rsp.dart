/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

/// A L0 Storage Policy Response Model
class L0StorageModelPolicyRsp {
  DateTime? expires;
  String? keyPrefix;
  List<String>? compute;
  int? maxBytes;
  Map<String, String>? fields;

  L0StorageModelPolicyRsp(
      {this.expires, this.keyPrefix, this.compute, this.maxBytes, this.fields});

  L0StorageModelPolicyRsp.fromMap(Map<String, dynamic>? map) {
    if (map != null) {
      keyPrefix = map['keyPrefix'];
      maxBytes = map['maxBytes'];
      if (map['expires'] != null) {
        expires = DateTime.tryParse(map['expires']);
      }
      if (map['compute'] != null) {
        compute = List.from(map['compute']);
      }
      fields = Map.from(map['fields']);
    }
  }

  Map<String, dynamic> toMap() => {
        'expires': expires?.toIso8601String(),
        'keyPrefix': keyPrefix,
        'maxBytes': maxBytes,
        'compute': compute,
        'fields': fields
      };

  @override
  String toString() {
    return 'L0StorageModelPolicyRsp{expires: $expires, keyPrefix: $keyPrefix, compute: $compute, maxBytes: $maxBytes, fields: $fields}';
  }
}
