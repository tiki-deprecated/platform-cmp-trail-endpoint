/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:uuid/uuid.dart';

import '../../node/backup/backup_client.dart';
import '../../utils/rsa/rsa.dart';
import '../../utils/rsa/rsa_private_key.dart';
import '../auth/auth_service.dart';
import 'storage_model_list.dart';
import 'storage_model_list_ver.dart';
import 'storage_model_token_req.dart';
import 'storage_model_token_rsp.dart';
import 'storage_model_upload.dart';
import 'storage_repository.dart';

/// The primary class for interaction with the
/// [L0 Storage](https://github.com/tiki/l0-storage) Service.
///
/// Use to [read] objects from and [write] to the hosted storage.
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

  /// Convenience constructor using [publishingId]
  ///
  /// On construction a new [AuthService] with the [publishingId] is created
  StorageService.publishingId(RsaPrivateKey privateKey, String publishingId)
      : _repository = StorageRepository(),
        _privateKey = privateKey,
        _authService = AuthService(publishingId),
        super();

  /// Read a binary object from hosted storage
  ///
  /// Returns the **first** version of an object stored with the
  /// specified [key].
  ///
  /// The [key] is automatically prefixed with the application identifier
  /// derived from the //urnPrefix described in [StorageModelTokenRsp] and
  /// fetched using the [publishingId].
  ///
  /// DO use the full key path, including file type  (e.g., .block, .txt)
  @override
  Future<Uint8List?> read(String key) async {
    _token ??= await _requestToken();
    try {
      StorageModelList versions =
          await _repository.versions('${_appId(_token?.urnPrefix)}/$key');
      String? versionId;
      if (versions.versions != null && versions.versions!.isNotEmpty) {
        versionId = _findFirst(versions.versions!).versionId;
      }
      return _repository.get('${_appId(_token?.urnPrefix)}/$key',
          versionId: versionId);
    } on HttpException catch (e) {
      if (e.message.contains('HTTP Error 404:')) {
        return null;
      } else {
        rethrow;
      }
    }
  }

  /// Write a binary object to hosted storage
  ///
  /// The [key] is automatically prefixed with the application identifier
  /// derived from the //urnPrefix described in [StorageModelTokenRsp] and
  /// fetched using the [publishingId].
  ///
  /// If authorization fails (HTTP 401), an updated authorization token
  /// is requested and the method retried **once**.
  ///
  /// DO use the full key path, including file type  (e.g., .block, .txt)
  @override
  Future<void> write(String key, Uint8List value) async {
    _token ??= await _requestToken();
    StorageModelUpload req = StorageModelUpload(
        key: '${_appId(_token?.urnPrefix)}/$key', content: value);
    try {
      await _repository.upload(_token?.token, req);
    } on HttpException catch (e) {
      if (e.message.contains('HTTP Error 401')) {
        _token = await _requestToken();
        req.key = _appId(_token?.urnPrefix) + key;
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

  String _appId(String? s) => s != null ? s.split('/')[0] : '';
}
