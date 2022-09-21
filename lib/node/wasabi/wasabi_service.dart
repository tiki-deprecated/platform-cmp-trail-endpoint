/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */
/// {@category Node}
library wasabi;

import 'dart:io';
import 'dart:typed_data';

import 'wasabi_model_list.dart';
import 'wasabi_model_list_ver.dart';
import 'wasabi_repository.dart';

export 'wasabi_exception_expired.dart';
export 'wasabi_model_list.dart';
export 'wasabi_model_list_ver.dart';
export 'wasabi_repository.dart';

/// The service to use Wasabi object storage.
class WasabiService {
  final WasabiRepository _repository;

  WasabiService() : _repository = WasabiRepository();

  Future<Uint8List> read(String path) async {
    WasabiModelList versions = await _repository.versions(path);
    String? versionId;
    if (versions.versions != null && versions.versions!.isNotEmpty) {
      versionId = _first(versions.versions!).versionId;
    }
    return _repository.get(path, versionId: versionId);
  }

  Future<void> write(String path, Uint8List obj,
      {Map<String, String>? fields, int retries = 3}) async {
    try {
      await _repository.upload(path, obj, fields: fields);
    } on SocketException catch (_) {
      if (retries > 0) {
        return write(path, obj, fields: fields, retries: retries - 1);
      } else {
        rethrow;
      }
    }
  }

  WasabiModelListVer _first(List<WasabiModelListVer> versions) {
    WasabiModelListVer first = versions.first;
    if (versions.length > 1) {
      for (WasabiModelListVer version in versions) {
        if (version.lastModified!.isBefore(first.lastModified!)) {
          first = version;
        }
      }
    }
    return first;
  }
}
