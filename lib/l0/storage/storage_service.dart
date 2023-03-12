/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:uuid/uuid.dart';

import '../../node/backup/backup_client.dart';
import '../../node/xchain/xchain_client.dart';
import '../../utils/rsa/rsa.dart';
import '../../utils/rsa/rsa_private_key.dart';
import '../auth/auth_service.dart';
import 'storage_model_list.dart';
import 'storage_model_list_obj.dart';
import 'storage_model_token_req.dart';
import 'storage_model_token_rsp.dart';
import 'storage_model_upload.dart';
import 'storage_model_vlist.dart';
import 'storage_repository.dart';

/// The primary class for interaction with the
/// [L0 Storage](https://github.com/tiki/l0-storage) Service.
///
/// Use to [read] objects from and [write] to the hosted storage.
class StorageService implements BackupClient, XChainClient {
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
    String appId = _appId(_token?.urnPrefix);
    StorageModelUpload req =
        StorageModelUpload(key: '$appId/$key', content: value);
    try {
      await _repository.upload(_token?.token, req);
    } on HttpException catch (e) {
      if (e.message.contains('HTTP Error 401')) {
        _token = await _requestToken();
        await _repository.upload(_token?.token, req);
      } else {
        rethrow;
      }
    }
  }

  @override
  Future<Set<String>> list(String key) async {
    Set<String> rsp = {};
    _token ??= await _requestToken();
    String appId = _appId(_token?.urnPrefix);
    StorageModelList objList = await _repository.list('$appId/$key');
    rsp.addAll(objList.contents
            ?.skipWhile((obj) => obj.key == null)
            .map((obj) => obj.key!.replaceFirst('$appId/', '')) ??
        []);
    while (objList.isTruncated == true) {
      objList = await _repository.list('$appId/$key',
          marker: objList.contents?.last.key);
      rsp.addAll(objList.contents
              ?.skipWhile((obj) => obj.key == null)
              .map((obj) => obj.key!.replaceFirst('$appId/', '')) ??
          []);
    }

    return rsp;
  }

  @override
  Future<Uint8List?> read(String key) async {
    _token ??= await _requestToken();
    String appId = _appId(_token?.urnPrefix);
    List<StorageModelListObj> versions = [];
    try {
      StorageModelVList list = await _repository.versions('$appId/$key');
      versions.addAll(list.versions ?? []);
      while (list.isTruncated == true) {
        list = await _repository.versions('$appId/$key',
            versionMarker: list.versions?.last.versionId);
        versions.addAll(list.versions ?? []);
      }
      String? versionId;
      if (versions.isNotEmpty) {
        versionId = _findFirst(versions).versionId;
      }
      Uint8List rsp =
          await _repository.get('$appId/$key', versionId: versionId);
      return rsp;
    } on HttpException catch (e) {
      if (e.message.contains('HTTP Error 404:')) {
        return null;
      } else {
        rethrow;
      }
    }
  }

  StorageModelListObj _findFirst(List<StorageModelListObj> versions) {
    StorageModelListObj first = versions.first;
    if (versions.length > 1) {
      for (StorageModelListObj version in versions) {
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

  String _appId(String? s) => s?.split('/')[0] ?? '';
}
