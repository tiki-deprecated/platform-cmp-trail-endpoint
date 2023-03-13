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

/// The primary class for interaction with the
/// [L0 Registry](https://github.com/tiki/l0-registry) Service.
///
/// Use to register a wallet address to a customer id and
/// get addresses for a register id.
class RegistryService {
  final RsaPrivateKey _privateKey;
  final RegistryRepository _repository;
  final AuthService _authService;

  /// Requires an initialized [_authService] and the corresponding
  /// [_privateKey] for the address.
  RegistryService(this._privateKey, this._authService)
      : _repository = RegistryRepository();

  /// Returns the [RegistryModelRsp] for the [id]
  Future<RegistryModelRsp> get(String id) async {
    String? auth = await _authService.token;
    return _repository.addresses(id,
        signature: _signature(), authorization: auth);
  }

  /// Register the [id] [address] pair with the service. Returns the
  /// [RegistryModelRsp] for the [id].
  ///
  /// Optionally, include a [customerAuth] token (JWT) for headless
  /// verification of the user's identity. Requires configuration
  /// in the [console](https://console.mytiki.com)
  Future<RegistryModelRsp> register(String id, String address,
      {String? customerAuth}) async {
    String? auth = await _authService.token;
    return _repository.register(RegistryModelReq(id: id, address: address),
        signature: _signature(),
        authorization: auth,
        customerAuth: customerAuth);
  }

  /// Returns a signature using the [_privateKey] for a [message]
  String _signature({String? message}) {
    message ??= const Uuid().v4();
    Uint8List signature =
        Rsa.sign(_privateKey, Uint8List.fromList(utf8.encode(message)));
    return "$message.${base64.encode(_privateKey.public.bytes)}.${base64.encode(signature)}";
  }
}
