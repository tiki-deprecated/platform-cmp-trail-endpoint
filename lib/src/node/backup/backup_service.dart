import 'dart:typed_data';

import 'package:sqlite3/sqlite3.dart';

import '../../utils/rsa/rsa.dart';
import '../block/block_model.dart';
import '../block/block_service.dart';
import '../keys/keys_model.dart';
import '../keys/keys_service.dart';
import '../node_service.dart';
import '../wasabi/wasabi_service.dart';
import 'backup_model.dart';
import 'backup_model_asset_enum.dart';
import 'backup_repository.dart';

class BackupService {
  final String _address;
  final BackupRepository _repository;
  final WasabiService _wasabiService;
  final KeysService _keysService;
  final BlockService _blockService;

  BackupService(this._address, this._keysService, this._blockService,
      this._wasabiService, Database db)
      : _repository = BackupRepository(db) {
    _writePending();
  }

  void write(String assetId, BackupModelAssetEnum assetType,
      Uint8List signature) async {
    BackupModel bkpModel = BackupModel(
        assetId: assetId, assetType: assetType, signature: signature);
    _repository.save(bkpModel);
    _writePending();
  }

  void _writePending() async {
    List<BackupModel> pending = _repository.getPending();
    if (pending.isNotEmpty) {
      KeysModel key = (await _keysService.get(_address))!;
      for (BackupModel bkp in pending) {
        switch (bkp.assetType) {
          case BackupModelAssetEnum.pubkey:
            bkp.payload =
                Uint8List.fromList(key.privateKey.public.encode().codeUnits);
            break;
          case BackupModelAssetEnum.block:
            BlockModel? block = _blockService.get(bkp.assetId);
            if (block == null) {
              throw ArgumentError.value(bkp.assetId, 'Block not found');
            }
            bkp.payload = _blockService.serialize(block);
            break;
        }
        String path = '${NodeService.scheme}/$_address/${bkp.assetId}';
        if (bkp.assetType == BackupModelAssetEnum.pubkey) {
          path = '${NodeService.scheme}/public_key';
        }
        bkp.signature = sign(key.privateKey, bkp.payload!);
        String? bkpResult = await _wasabiService.write(path, bkp.serialize());
        if (bkpResult != null) {
          bkp.timestamp = DateTime.now();
          _repository.update(bkp);
        }
      }
    }
  }
}
