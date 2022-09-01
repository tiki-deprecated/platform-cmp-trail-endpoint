import '../node/keys/keys_secure_storage_interface.dart';

//todo is this the right place for this??

class MemSecStorage extends KeysSecureStorageInterface {
  Map<String, String> storage = {};

  @override
  Future<void> delete({required String key}) async => storage.remove(key);

  @override
  Future<String?> read({required String key}) async => storage[key];

  @override
  Future<void> write({required String key, required String value}) async =>
      storage[key] = value;
}
