import 'dart:convert';

import 'package:test/test.dart';
import 'package:tiki_sdk_dart/node/keys/key_model.dart';
import 'package:tiki_sdk_dart/node/keys/key_service.dart';

import '../../in_mem_keys.dart';

void main() {
  final InMemoryKeys secureStorage = InMemoryKeys();
  final KeysService keysService = KeysService(secureStorage);
  group('keys service tests', () {
    test('Create keys, save and retrieve', () async {
      KeysModel keys = await keysService.create();
      expect(keys.address.isEmpty, false);
      expect(keys.privateKey.encode().isEmpty, false);
      KeysModel? retrieveKeys =
          await keysService.get(base64.encode(keys.address));
      expect(retrieveKeys == null, false);
      expect(retrieveKeys!.address, keys.address);
      expect(retrieveKeys.privateKey.encode(), keys.privateKey.encode());
    });
  });
}
