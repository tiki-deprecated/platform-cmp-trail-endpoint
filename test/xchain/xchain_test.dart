/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:math';

import 'package:test/test.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:tiki_sdk_dart/src/node/xchain/xchain_model.dart';
import 'package:tiki_sdk_dart/src/node/xchain/xchain_repository.dart';
import 'package:tiki_sdk_dart/src/node/xchain/xchain_service.dart';
import 'package:tiki_sdk_dart/src/utils/rsa/rsa.dart';

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
      XchainModel chain_original = XchainModel(uri: "ORIGINAL");
      repository.save(chain_original);
      XchainModel chain_duplicate = XchainModel(uri: "ORIGINAL");
      expect(() => repository.save(chain_duplicate), throwsException);
      List<XchainModel> chains = repository.getAll();
      expect(chains.length, 4);
    });
  });
}

XchainModel _generateXchainModel() {
  return XchainModel(
      uri: String.fromCharCodes(
          List.generate(50, (index) => Random().nextInt(33) + 89)));
}
