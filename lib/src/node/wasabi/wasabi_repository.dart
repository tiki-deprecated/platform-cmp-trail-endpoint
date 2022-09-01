import 'wasabi_model_rsp.dart';

import '../bouncer/bouncer_service.dart';

class WasabiRepository {
  final BouncerService _bouncerService;

  WasabiRepository(String apiKey) : _bouncerService = BouncerService(apiKey);

  WasabiModelRsp get(String uri) {
    throw UnimplementedError();
  }

  WasabiModelRsp post(String payload) {
    throw UnimplementedError();
  }
}
