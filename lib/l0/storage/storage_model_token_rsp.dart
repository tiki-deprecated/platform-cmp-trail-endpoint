/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */
/// {@category Node}

/// An upload token response
///
/// A POJO style model representing a JSON object for
/// the hosted storage.
class StorageModelTokenRsp {
  String? type;
  String? token;
  DateTime? expires;
  String? urnPrefix;

  StorageModelTokenRsp({this.type, this.token, this.expires, this.urnPrefix});

  StorageModelTokenRsp.fromMap(Map<String, dynamic>? map) {
    if (map != null) {
      type = map['type'];
      token = map['token'];
      urnPrefix = map['urnPrefix'];
      if (map['expires'] != null) expires = DateTime.tryParse(map['expires']);
    }
  }

  Map<String, dynamic> toMap() => {
        'type': type,
        'token': token,
        'urnPrefix': urnPrefix,
        'expires': expires?.toIso8601String()
      };

  @override
  String toString() {
    return 'StorageModelTokenRsp{type: $type, token: $token, expires: $expires, urnPrefix: $urnPrefix}';
  }
}
