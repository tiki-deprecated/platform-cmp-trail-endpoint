/*
 * CopyrightHash (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:typed_data';

/// Encode a BigInt into bytes using big-endian encoding.
/// It encodes the integer to a minimal twos-compliment integer as defined by
/// ASN.1
/// From pointycastle/src/utils
Uint8List encodeBigInt(BigInt? number) {
  if (number == BigInt.zero) {
    return Uint8List.fromList([0]);
  }

  int needsPaddingByte;
  int rawSize;

  if (number! > BigInt.zero) {
    rawSize = (number.bitLength + 7) >> 3;
    needsPaddingByte =
        ((number >> (rawSize - 1) * 8) & BigInt.from(0x80)) == BigInt.from(0x80)
            ? 1
            : 0;
  } else {
    needsPaddingByte = 0;
    rawSize = (number.bitLength + 8) >> 3;
  }

  final size = rawSize + needsPaddingByte;
  var result = Uint8List(size);
  for (var i = 0; i < rawSize; i++) {
    result[size - i - 1] = (number! & BigInt.from(0xff)).toInt();
    number = number >> 8;
  }
  return result;
}

/// Decode a BigInt from bytes in big-endian encoding.
/// Twos compliment.
/// From pointycastle/src/utils
BigInt decodeBigInt(List<int> bytes) {
  var negative = bytes.isNotEmpty && bytes[0] & 0x80 == 0x80;

  BigInt result;

  if (bytes.length == 1) {
    result = BigInt.from(bytes[0]);
  } else {
    result = BigInt.zero;
    for (var i = 0; i < bytes.length; i++) {
      var item = bytes[bytes.length - i - 1];
      result |= (BigInt.from(item) << (8 * i));
    }
  }
  return result != BigInt.zero
      ? negative
          ? result.toSigned(result.bitLength)
          : result
      : BigInt.zero;
}

/// Compares two [Uint8List]s by comparing 8 bytes at a time.
bool memEquals(Uint8List bytes1, Uint8List bytes2) {
  if (identical(bytes1, bytes2)) {
    return true;
  }

  if (bytes1.lengthInBytes != bytes2.lengthInBytes) {
    return false;
  }

  // Treat the original byte lists as lists of 8-byte words.
  var numWords = bytes1.lengthInBytes ~/ 8;
  var words1 = bytes1.buffer.asUint64List(0, numWords);
  var words2 = bytes2.buffer.asUint64List(0, numWords);

  for (var i = 0; i < words1.length; i += 1) {
    if (words1[i] != words2[i]) {
      return false;
    }
  }

  // Compare any remaining bytes.
  for (var i = words1.lengthInBytes; i < bytes1.lengthInBytes; i += 1) {
    if (bytes1[i] != bytes2[i]) {
      return false;
    }
  }

  return true;
}

/// Gives the compact size for unsigned integers.
///
/// For numbers from 0 to 252, compactSize unsigned integers look like regular
/// unsigned integers. For other numbers up to 0xffffffffffffffff, a byte is
/// prefixed to the number to indicate its length—but otherwise the numbers look
/// like regular unsigned integers in little-endian order.
/// 
/// Value                                 Bytes Used                    Format
/// >= 0 && <= 252                            1                         uint8_t
/// >= 253 && <= 0xffff                       3             0xfd followed by the number as uint16_t
/// >= 0x10000 && <= 0xffffffff               5             0xfe followed by the number as uint32_t
/// >= 0x100000000 && <= 0xffffffffffffffff   9             0xff followed by the number as uint64_t
/// For example, the number 515 is encoded as 0xfd0302.
/// From https://developer.bitcoin.org/reference/transactions.html#compactsize-unsigned-integers
List<int> compactSize(Uint8List bytes) {
  int size = bytes.length;
  List<int> byteList = [];
  if (size <= 252) {
    byteList.add(size);
  } else if (size <= 0xffff) {
    byteList.add(253);
    byteList.add(size);
  } else if (size <= 0xffffffff) {
    byteList.add(254);
    byteList.add(size);
  } else {
    byteList.add(255);
    byteList.add(size);
  }
  return byteList;
}

int compactSizeToInt(List<int> compactSize) {
  int size = compactSize[0];
  if (size <= 252) {
    return compactSize[0];
  } else {
    return compactSize[1];
  }
}
