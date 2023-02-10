/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:nock/nock.dart';
import 'package:test/test.dart';
import 'package:tiki_sdk_dart/l0/auth/auth_model_jwt.dart';
import 'package:tiki_sdk_dart/l0/auth/auth_repository.dart';

import 'auth_nock.dart';

void main() {
  setUpAll(() => nock.init());
  setUp(() => nock.cleanAll());

  group('Auth Repository Tests', () {
    test('Grant - Success', () async {
      AuthNock nock = AuthNock();
      final Interceptor interceptor = nock.interceptor;

      AuthRepository repository = AuthRepository();
      AuthModelJwt jwt = await repository.grant(nock.clientId);

      expect(interceptor.isDone, true);
      expect(jwt.accessToken, nock.accessToken);
      expect(jwt.refreshToken, nock.refreshToken);
      expect(jwt.scope?.length, 1);
      expect(jwt.scope?[0], 'storage');
      expect(jwt.tokenType, 'Bearer');
      expect(jwt.expires?.isAfter(DateTime.now()), true);
    });
  });
}
