import 'package:test/test.dart';
import 'package:tiki_sdk_dart/node/key/key_service.dart';
import 'package:tiki_sdk_dart/utils/utils.dart';

import '../../in_mem_key.dart';

void main() {
  final InMemKeyStorage secureStorage = InMemKeyStorage();
  final KeyService keysService = KeyService(secureStorage);

  group('Key Service Tests', () {
    test('Create/Retrieve - Success', () async {
      KeyModel keys = await keysService.create();
      expect(keys.address.isEmpty, false);
      expect(keys.privateKey.encode().isEmpty, false);
      KeyModel? retrieveKeys =
          await keysService.get(Bytes.base64UrlEncode(keys.address));
      expect(retrieveKeys == null, false);
      expect(retrieveKeys!.address, keys.address);
      expect(retrieveKeys.privateKey.encode(), keys.privateKey.encode());
    });
  });
}
