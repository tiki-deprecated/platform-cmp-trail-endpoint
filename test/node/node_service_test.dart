import 'dart:typed_data';

import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';
import 'package:tiki_sdk_dart/node/l0_storage.dart';
import 'package:tiki_sdk_dart/node/node_service.dart';

import '../in_mem_key.dart';
import '../in_mem_l0_storage.dart';

void main() {
  group('Node tests', () {
    test('Init - No Primary - Success ', () async {
      L0Storage l0storage = InMemL0Storage();
      KeyStorage keyStorage = InMemKeyStorage();

      NodeService node = await NodeService()
          .init(sqlite3.openInMemory(), keyStorage, l0storage);

      Uint8List? publicKey = await l0storage.read('public.key');
      expect(publicKey != null, true);
    });

    test('Write - Success ', () async {});

    test('Re-init - With Primary - Success ', () async {});
  });
}
