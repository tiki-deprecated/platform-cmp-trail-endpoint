/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */
/// {@category Node}
library backup;

export 'backup_model.dart';
export 'backup_repository.dart';

import 'dart:convert';
import 'dart:typed_data';

import 'package:sqlite3/sqlite3.dart';

import '../../utils/utils.dart';
import '../block/block_model.dart';
import '../node_service.dart';

/// A service to handle the backup requests to [WasabiService].
class BackupService {
  final String _address;
  final BackupRepository _repository;
  final WasabiService _wasabiService;
  final KeysService _keysService;
  final BlockService _blockService;
  final TransactionService _transactionService;

  /// Creates a [BackupService] to handle backup requests to [_wasabiService] at
  /// the chain identified by [_address].
  ///
  /// It uses [_blockService] and [_transactionService] to build the serialized
  /// [BlockModel] that will be uploaded, and [_keysService] for the the public key.
  BackupService(this._address, this._keysService, this._blockService,
      this._transactionService, this._wasabiService, Database db)
      : _repository = BackupRepository(db) {
    _writePending();
  }

  /// Records a request to write the asset defined by the [path] to [_wasabiService].
  ///
  /// The request is received by [BackupService] and is added to the database.
  /// Afterwards it calls [_writePending] that will query the database for any
  /// [BackupModel] that was not processed yet and process it in FIFO order.
  /// TODO check if the path is already in the repository to avoid duplicates
  Future<void> write(String path) async {
    BackupModel bkpModel = BackupModel(path: path);
    _repository.save(bkpModel);
    await _writePending();
  }

  Future<void> _writePending() async {
    List<BackupModel> pending = _repository.getPending();
    if (pending.isNotEmpty) {
      KeysModel keys = (await _keysService.get(_address))!;
      for (BackupModel bkp in pending) {
        Uint8List obj;
        if (bkp.path == 'public.key') {
          obj = base64.decode(keys.privateKey.public.encode());
        } else {
          BlockModel? block = _blockService.get(bkp.path);
          if (block == null) continue;
          Uint8List body = _transactionService
              .serializeTransactions(base64.encode(block.id!));
          Uint8List serializedBlock = block.serialize(body);
          bkp.signature = UtilsRsa.sign(keys.privateKey, serializedBlock);
          bkp.path = '${bkp.path}.block';
          obj = (BytesBuilder()
                ..add(bkp.signature!)
                ..add(serializedBlock))
              .toBytes();
        }
        await _wasabiService.write(bkp.path, obj);

        bkp.timestamp = DateTime.now();
        _repository.update(bkp);
      }
    }
  }
}
