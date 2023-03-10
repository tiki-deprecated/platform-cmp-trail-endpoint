/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:typed_data';

import 'package:uuid/uuid.dart';

import '../../utils/rsa/rsa.dart';
import '../../utils/rsa/rsa_private_key.dart';
import '../auth/auth_service.dart';
import 'registry_model_req.dart';
import 'registry_model_rsp.dart';
import 'registry_repository.dart';

class RegistryService {
  final RsaPrivateKey _privateKey;
  final RegistryRepository _repository;
  final AuthService _authService;

  RegistryService(this._privateKey, this._authService)
      : _repository = RegistryRepository();

  Future<RegistryModelRsp> get(String id, {String? customerAuth}) async {
    String? auth = await _authService.token;
    return _repository.addresses(id,
        signature: _signature(),
        authorization: auth,
        customerAuth: customerAuth);
  }

  Future<RegistryModelRsp> register(String id, String address,
      {String? customerAuth}) async {
    String? auth = await _authService.token;
    return _repository.register(RegistryModelReq(id: id, address: address),
        signature: _signature(),
        authorization: auth,
        customerAuth: customerAuth);
  }

  String _signature({String? message}) {
    message ??= const Uuid().v4();
    Uint8List signature =
        Rsa.sign(_privateKey, Uint8List.fromList(utf8.encode(message)));
    return "$message.${base64.encode(_privateKey.public.bytes)}.${base64.encode(signature)}";
  }
}
