import 'wasabi_model.dart';
import 'wasabi_model_rsp.dart';
import 'wasabi_repository.dart';

class WasabiService {
  final WasabiRepository _repository;

  WasabiService(String apiKey) : _repository = WasabiRepository();

  Future<WasabiModel> read(String assetRef) async {
    WasabiModelRsp response = _repository.get(assetRef);
    if (response.code == 200) {
      WasabiModel data = WasabiModel.fromRsp(response);
      return data;
    }
    throw Exception(
        'Wasabi error: ${response.code} - ${response.message}. Response: $response');
  }

  Future<WasabiModel> write(String jsonData) async {
    WasabiModelRsp response = _repository.post(jsonData);
    if (response.code == 201) {
      WasabiModel data = WasabiModel.fromRsp(response);
      return data;
    }
    throw Exception(
        'Wasabi error: ${response.code} - ${response.message}. Response $response');
  }
}
