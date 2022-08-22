import 'keys_model.dart';
import 'keys_repository.dart';

class KeysService {
  KeysRepository _repository = KeysRepository();

  KeysModel create() {
    KeysModel keys = KeysModel();
    _repository.save(keys);
    // call backup to save pubkey
    return keys;
  }

  // address is sha3-256 public key

  Future<KeysModel?> get(String address) async => await _repository.get(address);

}
