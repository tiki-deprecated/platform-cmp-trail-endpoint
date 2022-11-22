import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:tiki_sdk_dart/tiki_sdk_destination.dart';

void main() {
  group('TIKI SDK Destination', () {
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
