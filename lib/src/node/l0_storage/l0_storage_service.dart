/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:tiki_sdk_dart/src/utils/rsa/rsa.dart' as rsa;
import 'package:uuid/uuid.dart';

import '../../utils/rsa/rsa_private_key.dart';
import 'l0_storage_model_policy_req.dart';
import 'l0_storage_model_policy_rsp.dart';
import 'l0_storage_repository.dart';

class L0StorageService {
  final L0StorageRepository _repository;
  final CryptoRSAPrivateKey _privateKey;

  L0StorageService(String apiId, CryptoRSAPrivateKey privateKey)
      : _repository = L0StorageRepository(apiId),
        _privateKey = privateKey;

  Future<L0StorageModelPolicyRsp> policy() async {
    String stringToSign = const Uuid().v4();
    Uint8List signature =
        rsa.sign(_privateKey, Uint8List.fromList(utf8.encode(stringToSign)));
    L0StorageModelPolicyRsp? rsp = await _repository.policy(
        L0StorageModelPolicyReq(
            pubKey: _privateKey.public.encode(),
            signature: base64Encode(signature),
            stringToSign: stringToSign), onFailure: (rsp) {
      throw HttpException(
          'HTTP Error ${rsp.statusCode}: ${jsonDecode(rsp.body)}');
    });
    return rsp!;
  }
}
