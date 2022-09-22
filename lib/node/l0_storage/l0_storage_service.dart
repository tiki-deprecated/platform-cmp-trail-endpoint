/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */
/// {@category Node}
library l0_storage;

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:uuid/uuid.dart';

import '../../utils/utils.dart';
import 'l0_storage_model_policy_req.dart';
import 'l0_storage_model_policy_rsp.dart';
import 'l0_storage_repository.dart';

export 'l0_storage_model_policy_req.dart';
export 'l0_storage_model_policy_rsp.dart';
export 'l0_storage_model_policy_rsp_fields.dart';
export 'l0_storage_repository.dart';
export 'l0_storage_service.dart';

/// Service to interact with L0 Storage APIs
class L0StorageService {
  final L0StorageRepository _repository;

  /// Construct a new instance of [L0StorageService]
  /// Requires a [apiId] provided by the
  /// [L0 Storage Service](https://github.com/tiki/l0-storage) team.
  /// Requires a [_privateKey] to sign all policy requests.
  L0StorageService(String apiId) : _repository = L0StorageRepository(apiId);

  /// Request a new [L0StorageModelPolicyRsp].
  ///
  /// If there is any HTTP response other than 200 the response
  /// is thrown as an [HttpException]. Other http client exceptions
  /// such as [SocketException] and [FormatException] are propagated.
  Future<L0StorageModelPolicyRsp> policy(CryptoRSAPrivateKey privateKey) async {
    String stringToSign = const Uuid().v4();
    Uint8List signature = UtilsRsa.sign(
        privateKey, Uint8List.fromList(utf8.encode(stringToSign)));
    return await _repository.policy(L0StorageModelPolicyReq(
        pubKey: privateKey.public.encode(),
        signature: base64Encode(signature),
        stringToSign: stringToSign));
  }
}
