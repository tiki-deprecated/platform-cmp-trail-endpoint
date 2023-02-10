/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */
/// {@category L0 Services}
library l0_auth;

import 'auth_repository.dart';

export 'auth_model_jwt.dart';
export 'auth_repository.dart';

class AuthService {
  final String _publishingId;
  final AuthRepository _repository;

  AuthService(this._publishingId) : _repository = AuthRepository();

  Future<String?> get token async =>
      (await _repository.grant(_publishingId)).accessToken;
}
