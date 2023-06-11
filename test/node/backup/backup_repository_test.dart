/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:typed_data';

import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';
import 'package:tiki_trail/node/backup/backup_model.dart';
import 'package:tiki_trail/node/backup/backup_repository.dart';
import 'package:uuid/uuid.dart';

void main() {
  group('Backup Repository Tests', () {
    test('Save/GetByPath - Success ', () async {
      Database database = sqlite3.openInMemory();
      BackupRepository repository = BackupRepository(database);

      String path = const Uuid().v4();
      DateTime timestamp = DateTime.now();
      Uint8List signature = Uint8List.fromList(utf8.encode(const Uuid().v4()));
      BackupModel backup =
          BackupModel(path: path, timestamp: timestamp, signature: signature);

      repository.save(backup);
      BackupModel? found = repository.getByPath(path);

      expect(found != null, true);
      expect(found?.path, path);
      expect(found?.timestamp,
          timestamp.subtract(Duration(microseconds: timestamp.microsecond)));
      expect(found?.signature, signature);
    });

    test('Update/GetPending - Success ', () async {
      Database database = sqlite3.openInMemory();
      BackupRepository repository = BackupRepository(database);

      String path = const Uuid().v4();
      Uint8List signature = Uint8List.fromList(utf8.encode(const Uuid().v4()));
      BackupModel backup =
          BackupModel(path: path, timestamp: null, signature: signature);

      repository.save(backup);
      List<BackupModel> pending = repository.getPending();
      expect(pending.length, 1);

      backup.timestamp = DateTime.now();
      repository.update(backup);

      pending = repository.getPending();
      expect(pending.length, 0);
    });
  });
}
