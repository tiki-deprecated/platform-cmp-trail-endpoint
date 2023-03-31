/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:typed_data';

/// Compact Size operations.
///
/// From [bitcoin](https://developer.bitcoin.org/reference/transactions.html#compactsize-unsigned-integers)
///
/// For numbers from 0 to 252, compactSize unsigned integers look like regular
/// unsigned integers. For other numbers up to 0xffffffffffffffff, a byte is
/// prefixed to the number to indicate its length.
class CompactSize {
  /// Encodes a [Uint8List] into a compact size prepended Uint8List.
  static Uint8List encode(Uint8List uint8list) {
    Uint8List cSize = toSize(uint8list);
    return (BytesBuilder()
          ..add(cSize)
          ..add(uint8list))
        .toBytes();
  }

  /// Decodes a compact size prepended Uint8List.
  static List<Uint8List> decode(Uint8List bytes) {
    List<Uint8List> extractedBytes = [];
    int currentSize = 0;
    for (int i = 0; i < bytes.length; i += currentSize) {
      currentSize = toInt(bytes.sublist(i));
      if (bytes[i] <= 252) {
        i++;
      } else if (bytes[i] == 253) {
        i += 3;
      } else if (bytes[i] == 254) {
        i += 5;
      } else {
        i += 9;
      }
      Uint8List currentBytes = bytes.sublist(i, i + currentSize);
      extractedBytes.add(currentBytes);
    }
    return extractedBytes;
  }

  /// Converts a [Uint8List] into its compact size representation.
  static Uint8List toSize(Uint8List bytes) {
    int size = bytes.length;
    BytesBuilder byteList = BytesBuilder();
    if (size <= 252) {
      byteList.addByte(size);
    } else if (size <= 0xffff) {
      byteList.addByte(253);
      Uint16List uint16list = Uint16List.fromList([size]);
      byteList.add(uint16list.buffer.asUint8List());
    } else if (size <= 0xffffffff) {
      byteList.addByte(254);
      Uint32List uint32list = Uint32List.fromList([size]);
      byteList.add(uint32list.buffer.asUint8List());
    } else {
      throw UnsupportedError(
          ">Uint32 length sizes are not unsupported. Pick a size under 4,294,967,295 bytes");
      // byteList.addByte(255);
      // Uint64List uint64list = Uint64List.fromList([size]);
      // byteList.add(uint64list.buffer.asUint8List());
    }
    return byteList.toBytes();
  }

  /// Converts a compact size [Uint8List] into [int].
  static int toInt(Uint8List compactSize) {
    int size = compactSize[0];
    Uint8List bytes;
    if (size <= 252) {
      return size;
    } else if (size == 253) {
      bytes = compactSize.sublist(1, 3);
    } else if (size == 254) {
      bytes = compactSize.sublist(1, 5);
    } else {
      bytes = compactSize.sublist(1, 9);
    }
    int value = 0;
    for (int i = bytes.length - 1; i >= 0; i--) {
      value = value << 8;
      value = value | bytes[i];
    }
    return value;
  }
}
