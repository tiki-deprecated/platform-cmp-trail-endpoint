/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:typed_data';

import 'package:nock/nock.dart';
import 'package:test/expect.dart';
import 'package:tiki_trail/l0/storage/storage_repository.dart';
import 'package:uuid/uuid.dart';

class StorageNock {
  final String token = const Uuid().v4();
  final DateTime expires = DateTime.now().add(const Duration(hours: 1));
  String urnPrefix = '${const Uuid().v4()}/${const Uuid().v4()}';
  final String firstVersion = const Uuid().v4();

  Interceptor get tokenInterceptor =>
      nock(StorageRepository.serviceUrl).post(StorageRepository.tokenPath, {
        'pubKey': const TypeMatcher<String>(),
        'signature': const TypeMatcher<String>(),
        'stringToSign': const TypeMatcher<String>(),
      })
        ..reply(
          200,
          jsonEncode({
            'type': 'Bearer',
            'token': token,
            'urnPrefix': urnPrefix,
            'expires': expires.toIso8601String()
          }),
        );

  Interceptor get uploadInterceptor =>
      nock(StorageRepository.serviceUrl).put(StorageRepository.uploadPath, {
        'key': const TypeMatcher<String>(),
        'content': const TypeMatcher<String>()
      })
        ..reply(201, null);

  Interceptor readInterceptor(String key, Uint8List value,
      {String? versionId}) {
    String versionQuery = versionId != null ? '?versionId=$versionId' : '';
    return nock(StorageRepository.bucketUrl).get('/$key$versionQuery')
      ..reply(200, value);
  }

  Interceptor versionInterceptor(String key) => nock(
          StorageRepository.bucketUrl)
      .get('?versions&prefix=$key')
    ..reply(200,
        '<?xml version="1.0" encoding="UTF-8"?><ListVersionsResult xmlns="http://s3.amazonaws.com/doc/2006-03-01/"><Name>bucket.storage.l0.mytiki.com</Name><Prefix>$key</Prefix><KeyMarker></KeyMarker><VersionIdMarker></VersionIdMarker><MaxKeys>1000</MaxKeys><IsTruncated>false</IsTruncated><Version><Key>$key</Key><VersionId>001668315727778637414-1iaG2sp0uR</VersionId><IsLatest>true</IsLatest><LastModified>2022-11-13T05:02:08.000Z</LastModified><ETag>&quot;d7599e7efefde422a5f27fbed4de5793&quot;</ETag><Size>21</Size><Owner><ID>31393050501140202423139305050114020242</ID><DisplayName>test</DisplayName></Owner><StorageClass>STANDARD</StorageClass></Version><Version><Key>$key</Key><VersionId>001668315604818680587-y7WU2IApAT</VersionId><IsLatest>false</IsLatest><LastModified>2022-11-13T05:00:05.000Z</LastModified><ETag>&quot;d7599e7efefde422a5f27fbed4de5793&quot;</ETag><Size>21</Size><Owner><ID>31393050501140202423139305050114020242</ID><DisplayName>test</DisplayName></Owner><StorageClass>STANDARD</StorageClass></Version><Version><Key>$key</Key><VersionId>001668315556370961452-Q1X3Ned38w</VersionId><IsLatest>false</IsLatest><LastModified>2022-11-13T04:59:16.000Z</LastModified><ETag>&quot;d7599e7efefde422a5f27fbed4de5793&quot;</ETag><Size>21</Size><Owner><ID>31393050501140202423139305050114020242</ID><DisplayName>test</DisplayName></Owner><StorageClass>STANDARD</StorageClass></Version><Version><Key>$key</Key><VersionId>001668315505194349095-ToGEACsU9m</VersionId><IsLatest>false</IsLatest><LastModified>2022-11-13T04:58:25.000Z</LastModified><ETag>&quot;d7599e7efefde422a5f27fbed4de5793&quot;</ETag><Size>21</Size><Owner><ID>31393050501140202423139305050114020242</ID><DisplayName>test</DisplayName></Owner><StorageClass>STANDARD</StorageClass></Version><Version><Key>$key</Key><VersionId>001668315486345680288-B6qp8zNrnA</VersionId><IsLatest>false</IsLatest><LastModified>2022-11-13T04:58:06.000Z</LastModified><ETag>&quot;d7599e7efefde422a5f27fbed4de5793&quot;</ETag><Size>21</Size><Owner><ID>31393050501140202423139305050114020242</ID><DisplayName>test</DisplayName></Owner><StorageClass>STANDARD</StorageClass></Version><Version><Key>$key</Key><VersionId>001668315438349991087-K7_y3eUX7z</VersionId><IsLatest>false</IsLatest><LastModified>2022-11-13T04:57:18.000Z</LastModified><ETag>&quot;d7599e7efefde422a5f27fbed4de5793&quot;</ETag><Size>21</Size><Owner><ID>31393050501140202423139305050114020242</ID><DisplayName>test</DisplayName></Owner><StorageClass>STANDARD</StorageClass></Version><Version><Key>$key</Key><VersionId>$firstVersion</VersionId><IsLatest>false</IsLatest><LastModified>2022-11-13T04:55:13.000Z</LastModified><ETag>&quot;d7599e7efefde422a5f27fbed4de5793&quot;</ETag><Size>21</Size><Owner><ID>31393050501140202423139305050114020242</ID><DisplayName>test</DisplayName></Owner><StorageClass>STANDARD</StorageClass></Version></ListVersionsResult>');
}
