/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:typed_data';

import 'package:sqlite3/common.dart';
import 'package:tiki_idp/tiki_idp.dart';

import '../../key.dart';
import '../../utils/bytes.dart';
import '../../utils/compact_size.dart';
import 'backup_client.dart';
import 'backup_model.dart';
import 'backup_repository.dart';

/// A service to handle block backups
class BackupService {
  final BackupRepository _repository;
  final BackupClient _client;
  final TikiIdp _idp;
  final Uint8List? Function(Uint8List) _getBlock;
  final Key _key;

  /// Creates a new BackupService
  ///
  /// Saves the public key in the initialization.
  BackupService(this._client, this._idp, CommonDatabase database,
      this._getBlock, this._key)
      : _repository = BackupRepository(database);

  Future<BackupService> init() async {
    String keyBackupPath = '${_key.address}/public.key';
    BackupModel? keyBackup = _repository.getByPath(keyBackupPath);
    if (keyBackup == null) {
      keyBackup = BackupModel(path: keyBackupPath);
      _repository.save(keyBackup);
    }
    if (keyBackup.timestamp == null) {
      String publicKey = await _idp.export(_key.id, public: true);
      Uint8List obj = base64.decode(publicKey);
      _client.write(keyBackupPath, obj);
      keyBackup.timestamp = DateTime.now();
      _repository.update(keyBackup);
    }
    _pending();
    return this;
  }

  /// Serializes a block and sends to the l0 storage
  Future<void> block(Uint8List id) async {
    BackupModel bkpModel =
        BackupModel(path: '${_key.address}/${Bytes.base64UrlEncode(id)}.block');
    _repository.save(bkpModel);
    return _pending();
  }

  Future<void> _pending() async {
    List<BackupModel> pending = _repository.getPending();
    if (pending.isNotEmpty) {
      for (BackupModel backup in pending) {
        if (backup.path.startsWith(_key.address)) {
          String noAddress = backup.path.replaceFirst('${_key.address}/', '');
          String id = noAddress.substring(0, noAddress.length - 6);
          Uint8List? block = _getBlock(Bytes.base64UrlDecode(id));
          if (block != null) {
            Uint8List signature = await _idp.sign(_key.id, block);
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
