/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'auth_repository.dart';

class AuthService {
  final String _publishingId;
  final AuthRepository _repository;

  AuthService(this._publishingId) : _repository = AuthRepository();

  Future<String?> get token async =>
      (await _repository.grant(_publishingId)).accessToken;
}
