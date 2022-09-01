//TODO this should be a repository interface
abstract class KeysSecureStorageInterface {
  Future<void> write({required String key, required String value});

  Future<String?> read({required String key});

  Future<void> delete({required String key});
}
