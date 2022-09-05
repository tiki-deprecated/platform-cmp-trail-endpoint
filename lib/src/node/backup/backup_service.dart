import 'package:sqlite3/sqlite3.dart';

import '../../utils/json_object.dart';
import '../wasabi/wasabi_model.dart';
import '../wasabi/wasabi_service.dart';
import 'backup_model.dart';
import 'backup_repository.dart';

class BackupService {
  final BackupRepository _repository;

  final WasabiService _wasabiService;

  BackupService(Database db, this._wasabiService)
      : _repository = BackupRepository(db);

  /// Saves the [jsonObj] remotely via [WasabiService] by its [assetRef].
  Future<BackupModel> write(String assetRef, JsonObject jsonObj) async {
    String payload = jsonObj.toJson();
    //WasabiModel wasabiRsp = await _wasabiService.write(payload);
    WasabiModel wasabiRsp = WasabiModel(id: null, payload: payload);
    BackupModel bkpModel = BackupModel(
      id: wasabiRsp.id,
      assetRef: assetRef,
      signature: wasabiRsp.signature ?? '',
      timestamp: wasabiRsp.timestamp ?? DateTime(0),
    );
    _repository.save(bkpModel);
    return bkpModel;
  }

  //TODO why? this is in the xchain.
  /// Reads the object remotely via [WasabiService] by its [assetRef].
  Future<JsonObject?> read(String assetRef, {forceAll = false}) async {
    int lastBkpTimestamp = 0;
    BackupModel? bkpModel = _repository.getByAssetRef(assetRef);
    if (bkpModel != null) {
      lastBkpTimestamp = bkpModel.timestamp.millisecondsSinceEpoch ~/ 1000;
    }
    //WasabiModel wasabiRsp = await _wasabiService.read(assetRef);
    WasabiModel wasabiRsp = WasabiModel(id: '', payload: '');
    JsonObject jsonObj = JsonObject.fromJson(wasabiRsp.payload!);
    if (!forceAll) {
      if (jsonObj.data is List) {
        List listData = jsonObj.data as List;
        int i =
            listData.indexWhere((map) => map['timestamp'] > lastBkpTimestamp);
        if (i >= 0) {
          jsonObj.data = listData.sublist(i);
        }
        if (jsonObj.data.isEmpty) return null;
      }
      if (jsonObj.data is Map && jsonObj.data['timestamp'] < lastBkpTimestamp) {
        return null;
      }
    }
    bkpModel = BackupModel(
      id: wasabiRsp.id,
      assetRef: assetRef,
      signature: wasabiRsp.signature!,
      timestamp: wasabiRsp.timestamp!,
    );
    _repository.save(bkpModel);
    return JsonObject.fromJson(wasabiRsp.payload!);
  }
}
