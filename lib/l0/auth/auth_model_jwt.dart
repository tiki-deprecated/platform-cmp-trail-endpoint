/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

class AuthModelJwt {
  String? accessToken;
  String? refreshToken;
  String? scope;
  String? tokenType;
  DateTime? expires;

  AuthModelJwt(
      {this.accessToken,
      this.refreshToken,
      this.scope,
      this.tokenType,
      this.expires});

  AuthModelJwt.fromMap(Map<String, dynamic>? map) {
    if (map != null) {
      accessToken = map['access_token'];
      refreshToken = map['refresh_token'];
      scope = map['scope'];
      tokenType = map['token_type'];
      int? expiresIn = map['expires_in'];
      if (expiresIn != null) {
        expires = DateTime.now().add(Duration(seconds: expiresIn));
      }
    }
  }

  @override
  String toString() {
    return 'AuthModelJwt{accessToken: $accessToken, refreshToken: $refreshToken, scope: $scope, tokenType: $tokenType, expires: $expires}';
  }
}
