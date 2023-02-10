/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';

import 'package:nock/nock.dart';
import 'package:test/test.dart';
import 'package:tiki_sdk_dart/l0/auth/auth_model_jwt.dart';
import 'package:tiki_sdk_dart/l0/auth/auth_repository.dart';
import 'package:uuid/uuid.dart';

void main() {
  setUpAll(() => nock.init());
  setUp(() => nock.cleanAll());

  group('Auth Repository Tests', () {
    test('Grant - Success', () async {
      String clientId = const Uuid().v4();
      final interceptor =
          nock(AuthRepository.url).post(AuthRepository.grantPath)
            ..query({
              'grant_type': 'client_credentials',
              'scope': 'storage',
              'client_id': clientId,
              'client_secret': '',
            })
            ..reply(
              200,
              jsonEncode({
                'access_token': '1234',
                'refresh_token': '5678',
                'scope': 'storage',
                'token_type': 'Bearer',
                'expires_in': 600
              }),
            );

      AuthRepository repository = AuthRepository();
      AuthModelJwt jwt = await repository.grant(clientId);

      expect(interceptor.isDone, true);
      expect(jwt.accessToken, '1234');
      expect(jwt.refreshToken, '5678');
      expect(jwt.scope?.length, 1);
      expect(jwt.scope?[0], 'storage');
      expect(jwt.tokenType, 'Bearer');
      expect(jwt.expires?.isAfter(DateTime.now()), true);
    });
  });
}
