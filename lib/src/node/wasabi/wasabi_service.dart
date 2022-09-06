import '../backup/backup_model.dart';
import 'wasabi_model.dart';
import 'wasabi_model_rsp.dart';
import 'wasabi_repository.dart';

class WasabiService {
  final WasabiRepository _repository;

  WasabiService(String apiKey) : _repository = WasabiRepository(apiKey);

  Future<String?> read(String assetRef) async {
    WasabiModelRsp response = await _repository.get(assetRef);
    if (response.code == 200) {
      WasabiModel data = WasabiModel.fromRsp(response);
      return data.payload;
    }
    throw Exception(
        'Wasabi error: ${response.code} - ${response.message}. Response: $response');
  }

  Future<BackupModel> write(BackupModel bkp) async {
    WasabiModelRsp response =
        await _repository.post(bkp.payload!, bkp.signature);
    if (response.code == 201) {
      WasabiModel data = WasabiModel.fromRsp(response);
      bkp.timestamp = data.timestamp;
      return bkp;
    }
    throw Exception('''Wasabi error: ${response.code} - ${response.message}. 
           Response $response.
           BackupModel $bkp''');
  }
}
