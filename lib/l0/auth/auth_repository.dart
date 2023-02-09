/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'auth_model_jwt.dart';

class AuthRepository {
  final Uri _serviceUri = Uri(scheme: 'https', host: 'auth.l0.mytiki.com');

  Future<AuthModelJwt> grant(String? clientId, {String? clientSecret}) async {
    http.Response rsp = await http.post(
        _serviceUri.replace(path: '/api/latest/oauth/token', queryParameters: {
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
