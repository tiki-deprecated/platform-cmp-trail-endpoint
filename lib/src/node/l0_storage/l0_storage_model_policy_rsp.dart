/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'l0_storage_model_policy_rsp_fields.dart';

/// A L0 Storage Policy Response Model
class L0StorageModelPolicyRsp {
  DateTime? expires;
  String? keyPrefix;
  List<String>? compute;
  int? maxBytes;
  L0StorageModelPolicyRspFields? fields;

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
      fields = L0StorageModelPolicyRspFields.fromMap(map['fields']);
    }
  }

  Map<String, dynamic> toMap() => {
        'expires': expires?.toIso8601String(),
        'keyPrefix': keyPrefix,
        'maxBytes': maxBytes,
        'compute': compute,
        'fields': fields?.toMap()
      };

  @override
  String toString() {
    return 'L0StorageModelPolicyRsp{expires: $expires, keyPrefix: $keyPrefix, compute: $compute, maxBytes: $maxBytes, fields: $fields}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is L0StorageModelPolicyRsp &&
          runtimeType == other.runtimeType &&
          expires == other.expires &&
          keyPrefix == other.keyPrefix &&
          compute == other.compute &&
          maxBytes == other.maxBytes &&
          fields == other.fields;

  @override
  int get hashCode =>
      expires.hashCode ^
      keyPrefix.hashCode ^
      compute.hashCode ^
      maxBytes.hashCode ^
      fields.hashCode;
}
