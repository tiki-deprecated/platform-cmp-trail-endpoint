/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */
/// The object storage service for the TIKI cloud.
library sstorage;

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:uuid/uuid.dart';

import '../../node/backup/backup_client.dart';
import '../../utils/rsa/rsa.dart';
import '../auth/auth_service.dart';
import 'storage_model_list.dart';
import 'storage_model_list_ver.dart';
import 'storage_model_token_req.dart';
import 'storage_model_token_rsp.dart';
import 'storage_model_upload.dart';
import 'storage_repository.dart';

class StorageService implements BackupClient {
  final StorageRepository _repository;
  final RsaPrivateKey _privateKey;
  final AuthService _authService;

  StorageModelTokenRsp? _token;

  StorageService(RsaPrivateKey privateKey, AuthService authService)
      : _repository = StorageRepository(),
        _privateKey = privateKey,
        _authService = authService,
        super();

  @override
  Future<Uint8List?> read(String path) async {
    try {
      StorageModelList versions =
          await _repository.versions('${_appId(_token?.urnPrefix)}/$path');
      String? versionId;
      if (versions.versions != null && versions.versions!.isNotEmpty) {
        versionId = _findFirst(versions.versions!).versionId;
      }
      return _repository.get('${_appId(_token?.urnPrefix)}/$path',
          versionId: versionId);
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
    _token ??= await _requestToken();
    StorageModelUpload req = StorageModelUpload(
        key: '${_appId(_token?.urnPrefix)}/$path', content: obj);
    try {
      await _repository.upload(_token?.token, req);
    } on HttpException catch (e) {
      if (e.message.contains('HTTP Error 401')) {
        _token = await _requestToken();
        req.key = _appId(_token?.urnPrefix) + path;
        await _repository.upload(_token?.token, req);
      } else {
        rethrow;
      }
    }
  }

  StorageModelListVer _findFirst(List<StorageModelListVer> versions) {
    StorageModelListVer first = versions.first;
    if (versions.length > 1) {
      for (StorageModelListVer version in versions) {
        if (version.lastModified!.isBefore(first.lastModified!)) {
          first = version;
        }
      }
    }
    return first;
  }

  Future<StorageModelTokenRsp> _requestToken() async {
    String stringToSign = const Uuid().v4();
    Uint8List signature =
        Rsa.sign(_privateKey, Uint8List.fromList(utf8.encode(stringToSign)));
    StorageModelTokenReq req = StorageModelTokenReq(
        pubKey: _privateKey.public.encode(),
        signature: base64Encode(signature),
        stringToSign: stringToSign);
    return await _repository.token(await _authService.token, req);
  }

  String _appId(String? path) => path != null ? path.split('/')[0] : '';
}
