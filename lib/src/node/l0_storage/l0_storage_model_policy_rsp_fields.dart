/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

/// A L0 Storage Policy Response Fields Model
class L0StorageModelPolicyRspFields {
  String? policy;
  String? contentType;
  String? xAmzCredential;
  String? xAmzAlgorithm;
  String? xAmzDate;
  String? xAmzSignature;
  String? xAmzObjectLockMode;
  String? xAmzObjectLockRetainUntilDate;

  L0StorageModelPolicyRspFields(
      {this.policy,
      this.contentType,
      this.xAmzCredential,
      this.xAmzAlgorithm,
      this.xAmzDate,
      this.xAmzSignature,
      this.xAmzObjectLockMode,
      this.xAmzObjectLockRetainUntilDate});

  L0StorageModelPolicyRspFields.fromMap(Map<String, dynamic>? map) {
    if (map != null) {
      policy = map['policy'];
      contentType = map['content-type'];
      xAmzCredential = map['x-amz-credential'];
      xAmzAlgorithm = map['x-amz-algorithm'];
      xAmzDate = map['x-amz-date'];
      xAmzSignature = map['x-amz-signature'];
      xAmzObjectLockMode = map['x-amz-object-lock-mode'];
      xAmzObjectLockRetainUntilDate =
          map['x-amz-object-lock-retain-until-date'];
    }
  }

  Map<String, dynamic> toMap() => {
        'policy': policy,
        'content-type': contentType,
        'x-amz-credential': xAmzCredential,
        'x-amz-algorithm': xAmzAlgorithm,
        'x-amz-date': xAmzDate,
        'x-amz-signature': xAmzSignature,
        'x-amz-object-lock-mode': xAmzObjectLockMode,
        'x-amz-object-lock-retain-until-date': xAmzObjectLockRetainUntilDate
      };

  @override
  String toString() {
    return 'L0StorageModelPolicyRspFields{policy: $policy, contentType: $contentType, xAmzCredential: $xAmzCredential, xAmzAlgorithm: $xAmzAlgorithm, xAmzDate: $xAmzDate, xAmzSignature: $xAmzSignature, xAmzObjectLockMode: $xAmzObjectLockMode, xAmzObjectLockRetainUntilDate: $xAmzObjectLockRetainUntilDate}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is L0StorageModelPolicyRspFields &&
          runtimeType == other.runtimeType &&
          policy == other.policy &&
          contentType == other.contentType &&
          xAmzCredential == other.xAmzCredential &&
          xAmzAlgorithm == other.xAmzAlgorithm &&
          xAmzDate == other.xAmzDate &&
          xAmzSignature == other.xAmzSignature &&
          xAmzObjectLockMode == other.xAmzObjectLockMode &&
          xAmzObjectLockRetainUntilDate == other.xAmzObjectLockRetainUntilDate;

  @override
  int get hashCode =>
      policy.hashCode ^
      contentType.hashCode ^
      xAmzCredential.hashCode ^
      xAmzAlgorithm.hashCode ^
      xAmzDate.hashCode ^
      xAmzSignature.hashCode ^
      xAmzObjectLockMode.hashCode ^
      xAmzObjectLockRetainUntilDate.hashCode;
}
