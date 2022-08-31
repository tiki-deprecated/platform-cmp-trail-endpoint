import 'dart:convert';

import 'wasabi_model.dart';
import 'wasabi_model_rsp.dart';
import 'wasabi_repository.dart';

class WasabiService {
  final WasabiRepository _repository;

  WasabiService(String apiKey) : _repository = WasabiRepository(apiKey);

  Future<WasabiModel<T>?> read<T>(String id) async {
    WasabiModelRsp response = await _repository.get(id);
    //WasabiModel<T> data = WasabiModel<T>.fromJson(response.payload);
    // if (response.code == 200 && _checkSignature(data)) {
    //   //
    // }
    return null;
  }

  Future<WasabiModel<T>?> write<T>(WasabiModel data) async {
    WasabiModelRsp response = await _repository.post(json.encode(data));
  }

  bool _checkSignature(WasabiModel data) {
    return true;
  }
}
