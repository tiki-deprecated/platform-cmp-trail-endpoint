import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';

import '../../utils/rsa/rsa.dart';
import '../secure_storage_sttgy_if.dart';
import 'keys_model.dart';
import 'keys_repository.dart';

class KeysService {
  final KeysRepository _repository;

  KeysService(SecureStorageStrategyIf secureStorageStrategy)
      : _repository = KeysRepository(secureStorageStrategy);

  /// Create a new [RsaKeyPair] and save its [RsaKeyPair.public] in object storage.
  Future<KeysModel> create() async {
    RsaKeyPair rsaKeyPair = await generateAsync();
    Uint8List address = Digest("SHA3-256")
        .process(base64.decode(rsaKeyPair.publicKey.encode()));
    KeysModel keys = KeysModel(
      address,
      rsaKeyPair.privateKey,
    );
    _repository.save(keys);
    return keys;
  }

  /// Get a [KeysModel] from [secureStorage]
  Future<KeysModel?> get(String address) async =>
      await _repository.get(address);
}
