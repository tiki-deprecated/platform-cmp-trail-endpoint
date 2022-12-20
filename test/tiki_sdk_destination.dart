import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:tiki_sdk_dart/tiki_sdk_destination.dart';

void main() {
  group('TIKI SDK Destination', () {

    test('from/to json', () {
      String json = '{"uses":["*"],"paths":["*"]}';
      TikiSdkDestination destination = TikiSdkDestination.fromJson(json);
      expect(destination.paths[0], "*");
      expect(destination.uses[0], "*");
    });

    test('serialization/deserialization', () async {
      TikiSdkDestination destination = const TikiSdkDestination.all();
      Uint8List serialized = destination.serialize();
      TikiSdkDestination deserialized =
          TikiSdkDestination.deserialize(serialized);
      expect(deserialized.paths[0], "*");
      expect(deserialized.uses[0], "*");
    });
  });
}
