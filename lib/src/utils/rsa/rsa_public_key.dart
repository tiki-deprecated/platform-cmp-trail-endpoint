/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/asn1/asn1_object.dart';
import 'package:pointycastle/asn1/asn1_parser.dart';
import 'package:pointycastle/asn1/primitives/asn1_bit_string.dart';
import 'package:pointycastle/asn1/primitives/asn1_integer.dart';
import 'package:pointycastle/asn1/primitives/asn1_object_identifier.dart';
import 'package:pointycastle/asn1/primitives/asn1_sequence.dart';
import 'package:pointycastle/asymmetric/api.dart';

class CryptoRSAPublicKey extends RSAPublicKey {
  CryptoRSAPublicKey(BigInt modulus, BigInt exponent)
      : super(modulus, exponent);

  static CryptoRSAPublicKey decode(String encodedKey) {
    ASN1Parser topLevelParser = ASN1Parser(base64.decode(encodedKey));
    ASN1Sequence topLevelSeq = topLevelParser.nextObject() as ASN1Sequence;

    ASN1BitString publicKeyBitString =
        topLevelSeq.elements![1] as ASN1BitString;
    ASN1Sequence publicKeySeq =
        ASN1Sequence.fromBytes(publicKeyBitString.stringValues as Uint8List);

    ASN1Integer modulus = publicKeySeq.elements![0] as ASN1Integer;
    ASN1Integer exponent = publicKeySeq.elements![1] as ASN1Integer;
    return CryptoRSAPublicKey(modulus.integer!, exponent.integer!);
  }

  String encode() {
    ASN1Sequence sequence = ASN1Sequence();
    ASN1Sequence algorithm = ASN1Sequence();
    ASN1Object paramsAsn1Obj =
        ASN1Object.fromBytes(Uint8List.fromList([0x5, 0x0]));
    algorithm
        .add(ASN1ObjectIdentifier.fromIdentifierString('1.2.840.113549.1.1.1'));
    algorithm.add(paramsAsn1Obj);

    ASN1Sequence publicKeySequence = ASN1Sequence();
    ASN1Integer modulus = ASN1Integer(this.modulus);
    ASN1Integer exponent = ASN1Integer(this.exponent);
    publicKeySequence.add(modulus);
    publicKeySequence.add(exponent);
    publicKeySequence.encode();
    ASN1BitString publicKeyBitString = ASN1BitString();
    publicKeyBitString.stringValues = publicKeySequence.encodedBytes;

    sequence.add(algorithm);
    sequence.add(publicKeyBitString);
    sequence.encode();
    return base64.encode(sequence.encodedBytes!);
  }
}
