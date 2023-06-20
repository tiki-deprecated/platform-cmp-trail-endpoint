/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';

import 'package:nock/nock.dart';
import 'package:tiki_idp/auth/auth_repository.dart';
import 'package:uuid/uuid.dart';

class AuthNock {
  final String clientId = const Uuid().v4();
  final String accessToken = const Uuid().v4();
  final String refreshToken = const Uuid().v4();
  final int expiresIn = 600;
  final String scope = 'storage registry';

  Interceptor get interceptor =>
      nock(AuthRepository.url).post(AuthRepository.grantPath)
        ..query({
          'grant_type': 'client_credentials',
          'scope': scope,
          'client_id': clientId,
          'client_secret': '',
        })
        ..reply(
          200,
          jsonEncode({
            'access_token': accessToken,
            'refresh_token': refreshToken,
            'scope': scope,
            'token_type': 'Bearer',
            'expires_in': expiresIn
          }),
        );
}
