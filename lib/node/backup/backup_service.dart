/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:typed_data';

import 'package:sqlite3/common.dart';

import '../../utils/bytes.dart';
import '../../utils/compact_size.dart';
import '../../utils/rsa/rsa.dart';
import '../key/key_model.dart';
import 'backup_client.dart';
import 'backup_model.dart';
import 'backup_repository.dart';

/// A service to handle block backups
class BackupService {
  final BackupRepository _repository;
  final BackupClient _client;
  final KeyModel _key;
  final Uint8List? Function(Uint8List) _getBlock;

  /// Creates a new BackupService
  ///
  /// Saves the public key in the initialization.
  BackupService(
      this._client, CommonDatabase database, this._key, this._getBlock)
      : _repository = BackupRepository(database) {
    String keyBackupPath = '${Bytes.base64UrlEncode(_key.address)}/public.key';
    BackupModel? keyBackup = _repository.getByPath(keyBackupPath);

    if (keyBackup == null) {
      keyBackup = BackupModel(path: keyBackupPath);
      _repository.save(keyBackup);
    }

    if (keyBackup.timestamp == null) {
      Uint8List obj = base64.decode(_key.privateKey.public.encode());
      _client.write(keyBackupPath, obj);
      keyBackup.timestamp = DateTime.now();
      _repository.update(keyBackup);
    }

    _pending();
  }

  /// Serializes a block and sends to the l0 storage
  Future<void> block(Uint8List id) async {
    String b64address = Bytes.base64UrlEncode(_key.address);
    BackupModel bkpModel =
        BackupModel(path: '$b64address/${Bytes.base64UrlEncode(id)}.block');
    _repository.save(bkpModel);
    return _pending();
  }

  Future<void> _pending() async {
    String b64address = Bytes.base64UrlEncode(_key.address);
    List<BackupModel> pending = _repository.getPending();
    if (pending.isNotEmpty) {
      for (BackupModel backup in pending) {
        if (backup.path.startsWith(b64address)) {
          String noAddress = backup.path.replaceFirst('$b64address/', '');
          String id = noAddress.substring(0, noAddress.length - 6);
          Uint8List? block = _getBlock(Bytes.base64UrlDecode(id));
          if (block != null) {
            Uint8List signature = Rsa.sign(_key.privateKey, block);
            Uint8List signedBlock = (BytesBuilder()
                  ..add(CompactSize.encode(signature))
                  ..add(CompactSize.encode(block)))
                .toBytes();
            await _client.write(backup.path, signedBlock);
            backup.timestamp = DateTime.now();
            _repository.update(backup);
          }
        }
      }
    }
  }
}
