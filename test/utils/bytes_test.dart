import 'dart:math';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:tiki_sdk_dart/utils/bytes.dart';
import 'package:tiki_sdk_dart/utils/compact_size.dart' as compact_size;

void main() {
  group('bytes utils tests', () {
    test('encode and decode 100 BigInt', () {
      for (int i = 0; i < 99; i++) {
        int big = Random().nextInt(4294901760);
        Uint8List encoded = encodeBigInt(BigInt.from(big));
        int decoded = decodeBigInt(encoded).toInt();
        expect(decoded, big);
      }
      int big = Random().nextInt(65035);
      Uint8List encoded = encodeBigInt(BigInt.from(-big));
      int decoded = decodeBigInt(encoded).toInt();
      expect(decoded, -big);
    });
    test('compact uint size for all ranges', () async {
      Uint8List smallUint = Uint8List(250);
      Uint8List smallCompactSize = compact_size.toSize(smallUint);
      int smallSize = compact_size.toInt(smallCompactSize);
      expect(smallSize, 250);
      Uint8List uint = Uint8List(65535);
      Uint8List uintCompactSize = compact_size.toSize(uint);
      int uintSize = compact_size.toInt(uintCompactSize);
      expect(uintSize, 65535);
      Uint8List bigUint = Uint8List(294967295);
      Uint8List bigUintCompactSize = compact_size.toSize(bigUint);
      int bigUintSize = compact_size.toInt(bigUintCompactSize);
      expect(bigUintSize, 294967295);
    });
    test('compact size 100 random <= 252 sizes test', () async {
      for (int i = 0; i < 100; i++) {
        int tiny = Random().nextInt(252);
        Uint8List cSize = compact_size.toSize(Uint8List(tiny));
        int size = compact_size.toInt(cSize);
        expect(size, tiny);
      }
    });
    test('compact size 100 random sizes between 252 and 65535 test', () async {
      for (int i = 0; i < 100; i++) {
        int small = Random().nextInt(65283) + 252;
        Uint8List cSize = compact_size.toSize(Uint8List(small));
        int size = compact_size.toInt(cSize);
        expect(small, size);
      }
    });
    test('compact size 100 random sizes between 65535 and 4294967295 test',
        () async {
      for (int i = 0; i < 100; i++) {
        int big = Random().nextInt(4294901760) + 65535;
        Uint8List cSize = compact_size.toSize(Uint8List(big));
        int size = compact_size.toInt(cSize);
        expect(big, size);
      }
    });
    test('extract 100 serialized Uint8Lists prepended by Compact Size', () {
      List<int> sizes = [];
      BytesBuilder builder = BytesBuilder();
      for (int i = 0; i < 100; i++) {
        int size = Random().nextInt(1048560);
        sizes.add(size);
        builder.add(compact_size.encode(Uint8List(size)));
      }
      Uint8List bytes = builder.toBytes();
      List<Uint8List> extractedBytes = compact_size.decode(bytes);
      expect(extractedBytes.length, 100);
      for (int i = 0; i < extractedBytes.length; i++) {
        expect(extractedBytes[i].length, sizes[i]);
      }
    });
  });
}
