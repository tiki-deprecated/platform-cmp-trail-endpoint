/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */
/// {@category Node}
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:uuid/uuid.dart';

import '../../utils/utils.dart';
import 'policy_model_req.dart';
import 'policy_model_rsp.dart';
import 'policy_repository.dart';

/// Service to interact with L0 Storage APIs
class PolicyService {
  final PolicyRepository _repository;
  final RsaPrivateKey _privateKey;

  /// Construct a new instance of [PolicyService]
  /// Requires a [apiId] provided by the
  /// [L0 Storage Service](https://github.com/tiki/l0-storage) team.
  /// Requires a [_privateKey] to sign all policy requests.
  PolicyService(String apiId, this._privateKey)
      : _repository = PolicyRepository(apiId);

  /// Request a new [L0StorageModelPolicyRsp].
  ///
  /// If there is any HTTP response other than 200 the response
  /// is thrown as an [HttpException]. Other http client exceptions
  /// such as [SocketException] and [FormatException] are propagated.
  Future<PolicyModelRsp> request() async {
    String stringToSign = const Uuid().v4();
    Uint8List signature =
        Rsa.sign(_privateKey, Uint8List.fromList(utf8.encode(stringToSign)));
    return await _repository.policy(PolicyModelReq(
        pubKey: _privateKey.public.encode(),
        signature: base64Encode(signature),
        stringToSign: stringToSign));
  }
}
