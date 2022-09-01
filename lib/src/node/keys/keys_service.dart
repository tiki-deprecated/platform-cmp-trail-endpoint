import 'dart:convert';
import 'dart:typed_data';

import '../../utils/json_object.dart';
import '../../utils/mem_sec_storage.dart';
import '../../utils/rsa/rsa.dart';
import '../../utils/utils.dart';
import '../backup/backup_service.dart';
import '../xchain/xchain_model.dart';
import 'keys_model.dart';
import 'keys_repository.dart';

class KeysService {
  final KeysRepository _repository;
  final BackupService? _backupService;

  KeysService(secureStorage, [this._backupService])
      : _repository = KeysRepository(secureStorage ?? MemSecStorage());

  /// Create a new [RsaKeyPair] and save its [RsaKeyPair.public] in object storage.
  Future<KeysModel> create() async {
    RsaKeyPair rsaKeyPair = await generateAsync();
    Uint8List address = sha256(base64Url.decode(rsaKeyPair.publicKey.encode()));
    KeysModel keys = KeysModel(
      address,
      rsaKeyPair.privateKey,
    );
    String uri = 'tiki://${base64Url.encode(address)}';
    _repository.save(keys);
    XchainModel chain = XchainModel(
        uri: uri,
        pubkey: rsaKeyPair.publicKey.encode()); //TODO this doesn't belong here.
    _backupService?.write(uri,
        JsonObject.fromMap(chain.toMap())); //TODO this doesn't belong here.
    return keys;
  }

  /// Get a [KeysModel] from [secureStorage]
  Future<KeysModel?> get(String address) async =>
      await _repository.get(address);
}
