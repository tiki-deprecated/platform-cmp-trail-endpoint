/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/asn1/asn1_parser.dart';
import 'package:pointycastle/asn1/primitives/asn1_integer.dart';
import 'package:pointycastle/asn1/primitives/asn1_object_identifier.dart';
import 'package:pointycastle/asn1/primitives/asn1_octet_string.dart';
import 'package:pointycastle/asn1/primitives/asn1_sequence.dart';
import 'package:pointycastle/ecc/api.dart';

import 'crypto_ec_public_key.dart';

class CryptoECPrivateKey extends ECPrivateKey {
  CryptoECPrivateKey(BigInt? d, ECDomainParameters? parameters)
      : super(d, parameters);

  static CryptoECPrivateKey decode(String encodedKey) {
    ASN1Parser topLevelParser = ASN1Parser(base64.decode(encodedKey));
    ASN1Sequence topLevelSeq = topLevelParser.nextObject() as ASN1Sequence;

    ASN1Sequence algorithmSeq = topLevelSeq.elements![1] as ASN1Sequence;
    ASN1OctetString privateKeyOctet =
        topLevelSeq.elements![2] as ASN1OctetString;

    String curveName =
        (algorithmSeq.elements![1] as ASN1ObjectIdentifier).readableName!;
    ECDomainParameters ecDomainParameters = ECDomainParameters(curveName);

    ASN1Sequence privateKeySeq =
        ASN1Sequence.fromBytes(privateKeyOctet.octets as Uint8List);
    ASN1OctetString privateKeyValue =
        privateKeySeq.elements![1] as ASN1OctetString;
    ASN1Integer privateKeyBigInt =
        ASN1Integer.fromBytes(privateKeyValue.encodedBytes!);

    return CryptoECPrivateKey(privateKeyBigInt.integer, ecDomainParameters);
  }

  CryptoECPublicKey get public =>
      CryptoECPublicKey(parameters!.G * d, parameters);

  String encode() {
    ASN1Sequence sequence = ASN1Sequence();
    ASN1Integer version = ASN1Integer(BigInt.from(0));
    ASN1Sequence algorithm = ASN1Sequence();
    algorithm.add(ASN1ObjectIdentifier.fromName('ecPublicKey'));
    algorithm.add(ASN1ObjectIdentifier.fromName('prime256v1'));

    ASN1Sequence encodedPrivateKey = ASN1Sequence();
    ASN1Integer encodedPrivateKeyVersion = ASN1Integer(BigInt.from(1));
    ASN1OctetString encodedPrivateKeyValue = ASN1OctetString();
    ASN1Integer encodePrivateKeyBigInt = ASN1Integer(d);
    encodePrivateKeyBigInt.encode();
    encodedPrivateKeyValue.octets = encodePrivateKeyBigInt.valueBytes;
    encodedPrivateKey.add(encodedPrivateKeyVersion);
    encodedPrivateKey.add(encodedPrivateKeyValue);
    encodedPrivateKey.encode();

    ASN1OctetString privateKeyDer = ASN1OctetString();
    privateKeyDer.octets = encodedPrivateKey.encodedBytes;

    sequence.add(version);
    sequence.add(algorithm);
    sequence.add(privateKeyDer);
    sequence.encode();
    return base64.encode(sequence.encodedBytes!);
  }
}
