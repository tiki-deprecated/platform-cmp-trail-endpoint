import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';

import '../../utils/rsa/rsa.dart';
import '../../utils/utils.dart';
import '../backup/backup_service.dart';
import '../xchain/xchain_model.dart';
import '../xchain/xchain_service.dart';
import 'keys_model.dart';
import 'keys_repository.dart';

class KeysService {
  final KeysRepository _repository;
  final BackupService _backupService;

  KeysService(secureStorage, this._backupService)
      : _repository = KeysRepository(secureStorage);

  Future<KeysModel> create() async {
    RsaKeyPair rsaKeyPair = await generateAsync();
    Uint8List address = sha256(base64Url.decode(rsaKeyPair.publicKey.encode()));
    KeysModel keys = KeysModel(
      address,
      rsaKeyPair.privateKey,
    );
    String uri = 'tiki://${base64Url.encode(address)}';
    _repository.save(keys);
    XchainModel chain = XchainModel(uri: uri, pubkey: rsaKeyPair.publicKey.encode());
    _backupService.write(chain);
    return keys;
  }

  Future<KeysModel?> get(String address) async =>
      await _repository.get(address);
}
