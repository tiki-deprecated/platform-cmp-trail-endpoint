import 'dart:io';
import 'dart:typed_data';

import '../../utils/rsa/rsa_private_key.dart';
import '../l0_storage/l0_storage_model_policy_rsp.dart';
import '../l0_storage/l0_storage_service.dart';
import 'wasabi_exception_expired.dart';
import 'wasabi_model_list.dart';
import 'wasabi_model_list_ver.dart';
import 'wasabi_repository.dart';

class WasabiService {
  final WasabiRepository _repository;
  final L0StorageService _l0storageService;
  L0StorageModelPolicyRsp? policy;

  WasabiService(String apiId, CryptoRSAPrivateKey privateKey)
      : _repository = WasabiRepository(),
        _l0storageService = L0StorageService(apiId, privateKey);

  Future<Uint8List> read(String path) async {
    WasabiModelList versions = await _repository.versions(path);
    String? versionId;
    if (versions.versions != null && versions.versions!.isNotEmpty) {
      versionId = _first(versions.versions!).versionId;
    }
    return _repository.get(path, versionId: versionId);
  }

  Future<void> write(String path, Uint8List obj, {int retries = 3}) async {
    policy ??= await _l0storageService.policy();
    try {
      await _repository.upload(
          '${policy!.keyPrefix}$path', policy!.fields!, obj);
    } on WasabiExceptionExpired catch (_) {
      policy = await _l0storageService.policy();
      await _repository.upload(
          '${policy!.keyPrefix}$path', policy!.fields!, obj);
    } on SocketException catch (_) {
      if (retries > 0) {
        return write(path, obj, retries: retries - 1);
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
