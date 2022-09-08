/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:math';

import 'package:test/test.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:tiki_sdk_dart/src/node/xchain/xchain_model.dart';
import 'package:tiki_sdk_dart/src/node/xchain/xchain_repository.dart';

void main() {
  final db = sqlite3.openInMemory();
  group('xchain repository tests', () {
    XchainRepository repository = XchainRepository(db);
    test('save xchains, do not save dupliate uri', () {
      XchainModel chain1 = _generateXchainModel();
      XchainModel chain2 = _generateXchainModel();
      XchainModel chain3 = _generateXchainModel();
      repository.save(chain1);
      repository.save(chain2);
      repository.save(chain3);
      expect(1, 1);
      XchainModel chainOriginal = XchainModel(address: "ORIGINAL", pubkey: 'a');
      repository.save(chainOriginal);
      XchainModel chainDuplicate = XchainModel(address: "ORIGINAL", pubkey: 'a');
      expect(() => repository.save(chainDuplicate), throwsException);
      XchainModel? chain = repository.getByAddress("ORIGINAL");
      expect(chain!.address, "ORIGINAL");
    });
  });
}

XchainModel _generateXchainModel() {
  String key = String.fromCharCodes(
      List.generate(50, (index) => Random().nextInt(33) + 89));
  return XchainModel(pubkey: key, address: key);
}
