import 'dart:convert';
import 'dart:typed_data';

import 'package:sqlite3/sqlite3.dart';

import '../../utils/rsa/rsa.dart';
import '../block/block_model.dart';
import '../block/block_service.dart';
import '../keys/keys_model.dart';
import '../keys/keys_service.dart';
import '../transaction/transaction_service.dart';
import '../wasabi/wasabi_service.dart';
import 'backup_model.dart';
import 'backup_repository.dart';

class BackupService {
  final String _address;
  final BackupRepository _repository;
  final WasabiService _wasabiService;
  final KeysService _keysService;
  final BlockService _blockService;
  final TransactionService _transactionService;

  BackupService(this._address, this._keysService, this._blockService,
      this._transactionService, this._wasabiService, Database db)
      : _repository = BackupRepository(db) {
    _writePending();
  }

  void write(String path) async {
    BackupModel bkpModel = BackupModel(path: path);
    _repository.save(bkpModel);
    _writePending();
  }

  void _writePending() async {
    List<BackupModel> pending = _repository.getPending();
    if (pending.isNotEmpty) {
      KeysModel keys = (await _keysService.get(_address))!;
      for (BackupModel bkp in pending) {
        Uint8List obj;
        if (bkp.path == 'pubkey') {
          obj = base64.decode(keys.privateKey.public.encode());
        } else {
          BlockModel? block = _blockService.get(bkp.path);
          if (block == null) continue;
          Uint8List body = _transactionService
              .serializeTransactions(base64.encode(block.id!));
          Uint8List serializedBlock = block.serialize(body);
          bkp.signature = sign(keys.privateKey, serializedBlock);
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
