/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

/// An authorization token response
///
/// A POJO style model representing a JSON object for
/// the authorization service.
class AuthModelJwt {
  String? accessToken;
  String? refreshToken;
  List<String>? scope;
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
      tokenType = map['token_type'];
      scope = (map['scope'] as String?)?.split(' ');
      expires = DateTime.now().add(Duration(seconds: map['expires_in'] ?? 0));
    }
  }

  @override
  String toString() {
    return 'AuthModelJwt{accessToken: $accessToken, refreshToken: $refreshToken, scope: $scope, tokenType: $tokenType, expires: $expires}';
  }
}
