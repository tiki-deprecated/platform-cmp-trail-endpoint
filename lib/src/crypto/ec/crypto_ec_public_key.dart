/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';

import 'package:pointycastle/asn1/asn1_parser.dart';
import 'package:pointycastle/asn1/primitives/asn1_bit_string.dart';
import 'package:pointycastle/asn1/primitives/asn1_object_identifier.dart';
import 'package:pointycastle/asn1/primitives/asn1_sequence.dart';
import 'package:pointycastle/ecc/api.dart';

class CryptoECPublicKey extends ECPublicKey {
  CryptoECPublicKey(ECPoint? Q, ECDomainParameters? parameters)
      : super(Q, parameters);

  static CryptoECPublicKey decode(String encodedKey) {
    ASN1Parser topLevelParser = ASN1Parser(base64.decode(encodedKey));
    ASN1Sequence topLevelSeq = topLevelParser.nextObject() as ASN1Sequence;

    ASN1Sequence algorithmSeq = topLevelSeq.elements![0] as ASN1Sequence;
    ASN1BitString publicKeyBitString =
        topLevelSeq.elements![1] as ASN1BitString;

    String curveName =
        (algorithmSeq.elements![1] as ASN1ObjectIdentifier).readableName!;
    ECDomainParameters ecDomainParameters = ECDomainParameters(curveName);
    ECPoint? Q =
        ecDomainParameters.curve.decodePoint(publicKeyBitString.stringValues!);

    return CryptoECPublicKey(Q, ecDomainParameters);
  }

  String encode() {
    ASN1Sequence sequence = ASN1Sequence();
    ASN1Sequence algorithm = ASN1Sequence();
    algorithm.add(ASN1ObjectIdentifier.fromName('ecPublicKey'));
    algorithm.add(ASN1ObjectIdentifier.fromName('prime256v1'));
    ASN1BitString publicKeyBitString = ASN1BitString();
    publicKeyBitString.stringValues = Q!.getEncoded(false);
    sequence.add(algorithm);
    sequence.add(publicKeyBitString);
    sequence.encode();

    return base64.encode(sequence.encodedBytes!);
  }
}
