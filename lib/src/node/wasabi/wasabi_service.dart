import 'dart:typed_data';

import 'wasabi_repository.dart';

class WasabiService {
  final WasabiRepository _repository;

  WasabiService(String apiKey) : _repository = WasabiRepository();

  Future<String?> read(String assetRef) async {
    return '';
  }

  Future<DateTime?> write(
      Uint8List payload, String destination, Uint8List signature) async {
    return DateTime.now();
  }
}
