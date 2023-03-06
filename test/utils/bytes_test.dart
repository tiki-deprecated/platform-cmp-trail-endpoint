import 'dart:math';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:tiki_sdk_dart/utils/bytes.dart';
import 'package:tiki_sdk_dart/utils/compact_size.dart';

void main() {
  group('Bytes Tests', () {
    test('Encode/Decode Decode - 100 BigInts - Success', () {
      for (int i = 0; i < 99; i++) {
        int big = Random().nextInt(4294901760);
        Uint8List encoded = Bytes.encodeBigInt(BigInt.from(big));
        int decoded = Bytes.decodeBigInt(encoded).toInt();
        expect(decoded, big);
      }
      int big = Random().nextInt(65035);
      Uint8List encoded = Bytes.encodeBigInt(BigInt.from(-big));
      int decoded = Bytes.decodeBigInt(encoded).toInt();
      expect(decoded, -big);
    });

    test('CompactSize Decode - All Ranges - Success', () async {
      Uint8List smallUint = Uint8List(250);
      Uint8List smallCompactSize = CompactSize.toSize(smallUint);
      int smallSize = CompactSize.toInt(smallCompactSize);
      expect(smallSize, 250);
      Uint8List uint = Uint8List(65535);
      Uint8List uintCompactSize = CompactSize.toSize(uint);
      int uintSize = CompactSize.toInt(uintCompactSize);
      expect(uintSize, 65535);
      Uint8List bigUint = Uint8List(294967295);
      Uint8List bigUintCompactSize = CompactSize.toSize(bigUint);
      int bigUintSize = CompactSize.toInt(bigUintCompactSize);
      expect(bigUintSize, 294967295);
    });

    test('CompactSize Decode - 100 Random <= 252 - Success', () async {
      for (int i = 0; i < 100; i++) {
        int tiny = Random().nextInt(252);
        Uint8List cSize = CompactSize.toSize(Uint8List(tiny));
        int size = CompactSize.toInt(cSize);
        expect(size, tiny);
      }
    });

    test('CompactSize Decode - 100 Random > 252 & <= 65535 - Success',
        () async {
      for (int i = 0; i < 100; i++) {
        int small = Random().nextInt(65283) + 252;
        Uint8List cSize = CompactSize.toSize(Uint8List(small));
        int size = CompactSize.toInt(cSize);
        expect(small, size);
      }
    });

    test('CompactSize Decode - 100 Random > 65535 & <= 4294967295 - Success',
        () async {
      for (int i = 0; i < 100; i++) {
        int big = Random().nextInt(4294901760) + 65535;
        Uint8List cSize = CompactSize.toSize(Uint8List(big));
        int size = CompactSize.toInt(cSize);
        expect(big, size);
      }
    });

    test('CompactSize Decode - 100 Random - Success', () {
      List<int> sizes = [];
      BytesBuilder builder = BytesBuilder();
      for (int i = 0; i < 100; i++) {
        int size = Random().nextInt(1048560);
        sizes.add(size);
        builder.add(CompactSize.encode(Uint8List(size)));
      }
      Uint8List bytes = builder.toBytes();
      List<Uint8List> extractedBytes = CompactSize.decode(bytes);
      expect(extractedBytes.length, 100);
      for (int i = 0; i < extractedBytes.length; i++) {
        expect(extractedBytes[i].length, sizes[i]);
      }
    });

    test('Hex Encode - Success', () {
      Uint8List bytes = Uint8List.fromList([0, 25, 104, 3]);
      String hex = Bytes.hexEncode(bytes);
      expect(hex, '00196803');
    });

    test('Base64Url no padding encode and decode', () {
      String str = "original string";
      Uint8List bytes = Uint8List.fromList(str.codeUnits);
      String b64 = Bytes.base64UrlEncode(bytes);
      Uint8List decodedBytes = Bytes.base64UrlDecode(b64);
      expect(str, String.fromCharCodes(decodedBytes));
    });
  });
}
