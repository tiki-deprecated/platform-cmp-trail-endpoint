import 'dart:math';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:tiki_sdk_dart/utils/utils.dart';

void main() {
  group('bytes utils tests', () {
    test('encode and decode 100 BigInt', () {
      for (int i = 0; i < 99; i++) {
        int big = Random().nextInt(4294901760);
        Uint8List encoded = UtilsBytes.encodeBigInt(BigInt.from(big));
        int decoded = UtilsBytes.decodeBigInt(encoded).toInt();
        expect(decoded, big);
      }
      int big = Random().nextInt(65035);
      Uint8List encoded = UtilsBytes.encodeBigInt(BigInt.from(-big));
      int decoded = UtilsBytes.decodeBigInt(encoded).toInt();
      expect(decoded, -big);
    });
    test('compact uint size for all ranges', () async {
      Uint8List smallUint = Uint8List(250);
      Uint8List smallCompactSize = UtilsCompactSize.toSize(smallUint);
      int smallSize = UtilsCompactSize.toInt(smallCompactSize);
      expect(smallSize, 250);
      Uint8List uint = Uint8List(65535);
      Uint8List uintCompactSize = UtilsCompactSize.toSize(uint);
      int uintSize = UtilsCompactSize.toInt(uintCompactSize);
      expect(uintSize, 65535);
      Uint8List bigUint = Uint8List(294967295);
      Uint8List bigUintCompactSize = UtilsCompactSize.toSize(bigUint);
      int bigUintSize = UtilsCompactSize.toInt(bigUintCompactSize);
      expect(bigUintSize, 294967295);
    });
    test('compact size 100 random <= 252 sizes test', () async {
      for (int i = 0; i < 100; i++) {
        int tiny = Random().nextInt(252);
        Uint8List cSize = UtilsCompactSize.toSize(Uint8List(tiny));
        int size = UtilsCompactSize.toInt(cSize);
        expect(size, tiny);
      }
    });
    test('compact size 100 random sizes between 252 and 65535 test', () async {
      for (int i = 0; i < 100; i++) {
        int small = Random().nextInt(65283) + 252;
        Uint8List cSize = UtilsCompactSize.toSize(Uint8List(small));
        int size = UtilsCompactSize.toInt(cSize);
        expect(small, size);
      }
    });
    test('compact size 100 random sizes between 65535 and 4294967295 test',
        () async {
      for (int i = 0; i < 100; i++) {
        int big = Random().nextInt(4294901760) + 65535;
        Uint8List cSize = UtilsCompactSize.toSize(Uint8List(big));
        int size = UtilsCompactSize.toInt(cSize);
        expect(big, size);
      }
    });
    test('extract 100 serialized Uint8Lists prepended by Compact Size', () {
      List<int> sizes = [];
      BytesBuilder builder = BytesBuilder();
      for (int i = 0; i < 100; i++) {
        int size = Random().nextInt(1048560);
        sizes.add(size);
        builder.add(UtilsCompactSize.encode(Uint8List(size)));
      }
      Uint8List bytes = builder.toBytes();
      List<Uint8List> extractedBytes = UtilsCompactSize.decode(bytes);
      expect(extractedBytes.length, 100);
      for (int i = 0; i < extractedBytes.length; i++) {
        expect(extractedBytes[i].length, sizes[i]);
      }
    });
  });
}
