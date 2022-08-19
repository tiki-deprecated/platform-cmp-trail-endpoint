import 'keystore_model.dart';
import 'keystore_repository.dart';

class KeystoreService {
  KeystoreRepository _repository = KeystoreRepository();

  KeystoreModel create() {
    KeystoreModel keys = KeystoreModel();
    _repository.save(keys);
    return keys;
  }

  Future<KeystoreModel?> get(String address) async => await _repository.get(address);

  void remove(String address) => _repository.delete(address);
}
