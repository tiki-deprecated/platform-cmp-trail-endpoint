import 'dart:convert';

import 'package:test/test.dart';
import 'package:tiki_sdk_dart/src/node/keys/keys_model.dart';
import 'package:tiki_sdk_dart/src/utils/keys_secure_storage_interface.dart';
import 'package:tiki_sdk_dart/src/node/keys/keys_service.dart';

void main() {
  final TestInMemoryStorage secureStorage = TestInMemoryStorage();
  final KeysService keysService = KeysService(secureStorage);
  group('keys service tests', () {
    test('Create keys, save and retrieve', () async {
      KeysModel keys = await keysService.create();
      expect(keys.address.isEmpty, false);
      expect(keys.privateKey.encode().isEmpty, false);
      KeysModel? retrieveKeys = await keysService.get(keys.address);
      expect(retrieveKeys == null, false);
      expect(retrieveKeys!.address, keys.address);
      expect(retrieveKeys.privateKey.encode(), keys.privateKey.encode());
    });
  });
}

class TestInMemoryStorage extends KeysSecureStorageInterface {
  Map<String, String> storage = {};

  @override
  Future<void> delete({required String key}) async => storage.remove(key);

  @override
  Future<String?> read({required String key}) async => storage[key];

  @override
  Future<void> write({required String key, required String value}) async =>
      storage[key] = value;
}
