/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */
/// 
import 'dart:io';
import 'dart:typed_data';

import '../node/l0_storage.dart';
import '../node/node_service.dart';
import '../utils/utils.dart';
import 'policy/policy_model_rsp.dart';
import 'policy/policy_service.dart';
import 'wasabi/wasabi_exception_expired.dart';

class SharedStorage implements L0Storage {
  static const String _customerId =
      'QTNa3Ypp6vkiZ8xvBY2Dch7f1qlvwHVTTXqx52hIVQc';

  final WasabiService _wasabiService;
  final PolicyService _policyService;

  PolicyModelRsp? _policy;

  SharedStorage(String apiId, RsaPrivateKey privateKey)
      : _wasabiService = WasabiService(),
        _policyService = PolicyService(apiId, privateKey),
        super();

  @override
  Future<Uint8List?> read(String path) async {
    try {
      Uint8List? rsp = await _wasabiService.read('$_customerId/$path');
      return rsp;
    } on HttpException catch (e) {
      if (e.message.contains('HTTP Error 404:')) {
        return null;
      } else {
        rethrow;
      }
    }
  }

  @override
  Future<void> write(String path, Uint8List obj) async {
    _policy ??= await _policyService.request();
    try {
      await _wasabiService.write('$_customerId/$path', obj,
          fields: _policy!.fields!);
    } on WasabiExceptionExpired catch (_) {
      _policy = await _policyService.request();
      await _wasabiService.write('$_customerId/$path', obj,
          fields: _policy!.fields!);
    }
  }

  @override
  Future<Map<String, Uint8List>> getAll(String address) {
    // TODO: implement getAll
    throw UnimplementedError();
  }
}
