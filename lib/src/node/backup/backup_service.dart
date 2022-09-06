import 'package:sqlite3/sqlite3.dart';

import '../keys/keys_model.dart';
import '../wasabi/wasabi_service.dart';
import 'backup_model.dart';
import 'backup_repository.dart';

class BackupService {
  final BackupRepository _repository;

  final WasabiService _wasabiService;

  final KeysModel _keys;

  BackupService(Database db, this._wasabiService, this._keys)
      : _repository = BackupRepository(db);

  void enqueue(String assetRef, String payload) async {
    BackupModel bkpModel = BackupModel(
        assetRef: assetRef, payload: payload, signKey: _keys.privateKey);
    _repository.save(bkpModel);
    proccess();
  }

  void proccess() async {
    List<BackupModel> pending = _repository.getPending();
    for (BackupModel bkp in pending) {
      BackupModel wasabiBkp = await _wasabiService.write(bkp);
      if (wasabiBkp.timestamp != null) {
        _repository.update(bkp);
      }
    }
  }
}
