/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'auth_model_jwt.dart';

/// Client-side implementation of authorization service APIs and
/// request/response marshalling for use by the [AuthService]
class AuthRepository {
  static const url = 'https://auth.l0.mytiki.com';
  static const grantPath = '/api/latest/oauth/token';
  final Uri _serviceUri = Uri.parse(url);

  /// Authorization token request grant.
  ///
  /// Requires valid [clientId] and depending on the issued credentials a
  /// [clientSecret].
  ///
  /// Returns a new authorization token ([AuthModelJwt])
  /// Throws [HttpException] for all non-200 HTTP responses
  Future<AuthModelJwt> grant(String? clientId, {String? clientSecret}) async {
    http.Response rsp = await http.post(
        _serviceUri.replace(path: grantPath, queryParameters: {
          'grant_type': 'client_credentials',
          'scope': 'storage',
          'client_id': clientId,
          'client_secret': clientSecret
        }),
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          "Accept": "application/json"
        });

    if (rsp.statusCode == 200) {
      return AuthModelJwt.fromMap(jsonDecode(rsp.body));
    } else {
      throw HttpException('HTTP Error ${rsp.statusCode}: ${rsp.body}');
    }
  }
}
