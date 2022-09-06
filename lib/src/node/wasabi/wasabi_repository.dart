import 'dart:typed_data';

import 'wasabi_model_rsp.dart';

import '../bouncer/bouncer_service.dart';

class WasabiRepository {
  final BouncerService _bouncerService;

  WasabiRepository(String apiKey) : _bouncerService = BouncerService(apiKey);

  Future<WasabiModelRsp> get(String uri) {
    throw UnimplementedError();
  }

  Future<WasabiModelRsp> post(String payload, Uint8List signature) {
    throw UnimplementedError();
  }
}
