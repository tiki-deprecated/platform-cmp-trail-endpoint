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

import '../node/backup/backup_client.dart';
import '../utils/rsa/rsa.dart';
import 'sstorage_model_list.dart';
import 'sstorage_model_list_ver.dart';
import 'sstorage_model_token_req.dart';
import 'sstorage_model_token_rsp.dart';
import 'sstorage_model_upload.dart';
import 'sstorage_repository.dart';

/// The [L0Storage] implementation for the TIKI cloud.
class SStorageService implements BackupClient {
  final SStorageRepository _repository;
  final RsaPrivateKey _privateKey;
  final String _apiId;

  SStorageModelTokenRsp? _token;

  /// Initializes a [SStorageService] using [apiId] for user identification and
  /// [privateKey] for signing token requests.
  SStorageService(String apiId, RsaPrivateKey privateKey)
      : _repository = SStorageRepository(),
        _privateKey = privateKey,
        _apiId = apiId,
        super();

  @override
  Future<Uint8List?> read(String path) async {
    try {
      SStorageModelList versions =
          await _repository.versions('${_customerId(_token?.urnPrefix)}/$path');
      String? versionId;
      if (versions.versions != null && versions.versions!.isNotEmpty) {
        versionId = _findFirst(versions.versions!).versionId;
      }
      return _repository.get('${_customerId(_token?.urnPrefix)}/$path',
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
    SStorageModelUpload req = SStorageModelUpload(
        key: '${_customerId(_token?.urnPrefix)}/$path', content: obj);
    try {
      await _repository.upload(_token?.token, req);
    } on HttpException catch (e) {
      if (e.message.contains('HTTP Error 401')) {
        _token = await _requestToken();
        req.key = _customerId(_token?.urnPrefix) + path;
        await _repository.upload(_token?.token, req);
      } else {
        rethrow;
      }
    }
  }

  @override
  Future<Map<String, Uint8List>> getAll(String address) =>
      throw UnimplementedError();

  SStorageModelListVer _findFirst(List<SStorageModelListVer> versions) {
    SStorageModelListVer first = versions.first;
    if (versions.length > 1) {
      for (SStorageModelListVer version in versions) {
        if (version.lastModified!.isBefore(first.lastModified!)) {
          first = version;
        }
      }
    }
    return first;
  }

  Future<SStorageModelTokenRsp> _requestToken() async {
    String stringToSign = const Uuid().v4();
    Uint8List signature =
        Rsa.sign(_privateKey, Uint8List.fromList(utf8.encode(stringToSign)));
    SStorageModelTokenReq req = SStorageModelTokenReq(
        pubKey: _privateKey.public.encode(),
        signature: base64Encode(signature),
        stringToSign: stringToSign);
    return await _repository.token(_apiId, req);
  }

  String _customerId(String? path) => path != null ? path.split('/')[0] : '';
}
