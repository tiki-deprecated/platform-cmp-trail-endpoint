abstract class KeysInterface {
  Future<void> write({required String key, required String value});

  Future<String?> read({required String key});

}
