import 'dart:convert';

import 'package:test/test.dart';
import 'package:tiki_sdk_dart/node/node_service.dart';

import '../../in_mem_keys.dart';

void main() {
  final InMemoryKeys secureStorage = InMemoryKeys();
  final KeyService keysService = KeyService(secureStorage);
  group('key service tests', () {
    test('Create keys, save and retrieve', () async {
      KeyModel key = await keysService.create();
      expect(key.address.isEmpty, false);
      expect(key.privateKey.encode().isEmpty, false);
      KeyModel? retrieveKey = await keysService.get(base64.encode(key.address));
      expect(retrieveKey == null, false);
      expect(retrieveKey!.address, key.address);
      expect(retrieveKey.privateKey.encode(), key.privateKey.encode());
    });
  });
}
