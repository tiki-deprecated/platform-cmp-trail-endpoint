/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:test/test.dart';
import 'package:tiki_trail/node/key/key_model.dart';
import 'package:tiki_trail/node/key/key_service.dart';

import '../../in_mem.dart';

void main() {
  final InMemKeyStorage secureStorage = InMemKeyStorage();
  final KeyService keysService = KeyService(secureStorage);

  group('Key Service Tests', () {
    test('Create/Retrieve - Success', () async {
      KeyModel keys = await keysService.create();
      expect(keys.address.isEmpty, false);
      expect(keys.privateKey.encode().isEmpty, false);
      KeyModel? retrieveKeys = await keysService.get(keys.id);
      expect(retrieveKeys == null, false);
      expect(retrieveKeys!.address, keys.address);
      expect(retrieveKeys.privateKey.encode(), keys.privateKey.encode());
    });
  });
}
