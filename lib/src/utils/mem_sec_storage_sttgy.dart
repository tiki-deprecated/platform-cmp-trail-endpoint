import '../node/secure_storage_sttgy_if.dart';

class MemSecureStorageStrategy extends SecureStorageStrategyIf {
  Map<String, String> storage = {};

  @override
  Future<void> delete({required String key}) async => storage.remove(key);

  @override
  Future<String?> read({required String key}) async => storage[key];

  @override
  Future<void> write({required String key, required String value}) async =>
      storage[key] = value;
}
