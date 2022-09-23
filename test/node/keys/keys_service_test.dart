import 'dart:convert';

import 'package:test/test.dart';
import 'package:tiki_sdk_dart/node/node_service.dart';

import '../../in_mem_key.dart';

void main() {
  final InMemoryKey secureStorage = InMemoryKey();
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
