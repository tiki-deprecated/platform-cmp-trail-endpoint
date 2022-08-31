import '../bouncer/bouncer_service.dart';
import 'wasabi_model.dart';

class WasabiRepository {
  final BouncerService _bouncerService;

  WasabiRepository(String apiKey) : _bouncerService = BouncerService(apiKey);

  get(String id) {}

  post(String payload) {}
}
