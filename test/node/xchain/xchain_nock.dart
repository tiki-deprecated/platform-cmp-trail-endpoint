/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';

import 'package:nock/nock.dart';
import 'package:test/expect.dart';
import 'package:tiki_sdk_dart/l0/storage/storage_repository.dart';

class XChainNock {
  String appId = '2ab3efdb-8e91-4148-a43b-a7c198b4d3d7';
  String address = 'KxUsCZPADYumvtpwkMkYILVH8PmX26IbbM_Z-v6cnkE';

  String b64Block =
      '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';
  String b64PubKey =
      'MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAsoJ9y2Hh5pANfDeuLtF9+B7pqVK27ujK4O1kqrB8wGRKXSxZf1jCnUy2PmFzxWECm5WNaVERCvO+aN+3MK10+FDW7EXsuqhtLp7Yi7NYI9N+v2g0nGzgLE9zzaOxy6hOIdUHWj4PYjazkM7reozmxZGpu8rnqPEsH6JzQRTOs74FwSTelHoEYmGeBmLXm9FZvI2DIAwKqazFGeKvXjc6n80x4rwRECw0fXLQsEHzCcuAZ25XXyZm4E3Eb+rHzCTw6tq4OB9gpYxaChkyrJgt9so4Scv9Dq7TsoAkG9AkFZAqETzf5etFjlWk5utw0bjiIXTbgMkODdxD/FtFeDwayQIDAQAB';
  String pubKeyVersions =
      '<?xml version="1.0" encoding="UTF-8"?><ListVersionsResult xmlns="http://s3.amazonaws.com/doc/2006-03-01/"><Name>bucket.storage.l0.mytiki.com</Name><Prefix>2ab3efdb-8e91-4148-a43b-a7c198b4d3d7/KxUsCZPADYumvtpwkMkYILVH8PmX26IbbM_Z-v6cnkE/public.key</Prefix><KeyMarker></KeyMarker><VersionIdMarker></VersionIdMarker><MaxKeys>1000</MaxKeys><IsTruncated>false</IsTruncated><Version><Key>2ab3efdb-8e91-4148-a43b-a7c198b4d3d7/KxUsCZPADYumvtpwkMkYILVH8PmX26IbbM_Z-v6cnkE/public.key</Key><VersionId>001676492961247080481-F6QqUecsqm</VersionId><IsLatest>true</IsLatest><LastModified>2023-02-15T20:29:21.000Z</LastModified><ETag>&quot;08d94f79018be96be11044bf07a7e688&quot;</ETag><Size>294</Size><Owner><ID>44C1CFE425214F4FFD42464A9DF70766B4723193F144BD7D74DB7190B44A4C03</ID><DisplayName>mike</DisplayName></Owner><StorageClass>STANDARD</StorageClass></Version></ListVersionsResult>';
  String blockList =
      '<?xml version="1.0" encoding="UTF-8"?><ListBucketResult xmlns="http://s3.amazonaws.com/doc/2006-03-01/"><Name>bucket.storage.l0.mytiki.com</Name><Prefix>2ab3efdb-8e91-4148-a43b-a7c198b4d3d7/KxUsCZPADYumvtpwkMkYILVH8PmX26IbbM_Z-v6cnkE</Prefix><Marker></Marker><MaxKeys>1000</MaxKeys><IsTruncated>false</IsTruncated><Contents><Key>2ab3efdb-8e91-4148-a43b-a7c198b4d3d7/KxUsCZPADYumvtpwkMkYILVH8PmX26IbbM_Z-v6cnkE/eBhsjwopFAC3-ybuVUvo2lkIfGLTB4PnPmWKBkUoV4M.block</Key><LastModified>2023-02-15T20:30:20.000Z</LastModified><ETag>&quot;8b063b026bcbfdf321a7d4ff0bc02075&quot;</ETag><Size>1518</Size><Owner><ID>44C1CFE425214F4FFD42464A9DF70766B4723193F144BD7D74DB7190B44A4C03</ID><DisplayName>mike</DisplayName></Owner><StorageClass>STANDARD</StorageClass></Contents><Contents><Key>2ab3efdb-8e91-4148-a43b-a7c198b4d3d7/KxUsCZPADYumvtpwkMkYILVH8PmX26IbbM_Z-v6cnkE/public.key</Key><LastModified>2023-02-15T20:29:21.000Z</LastModified><ETag>&quot;08d94f79018be96be11044bf07a7e688&quot;</ETag><Size>294</Size><Owner><ID>44C1CFE425214F4FFD42464A9DF70766B4723193F144BD7D74DB7190B44A4C03</ID><DisplayName>mike</DisplayName></Owner><StorageClass>STANDARD</StorageClass></Contents></ListBucketResult>';
  String blockVersions =
      '<?xml version="1.0" encoding="UTF-8"?><ListVersionsResult xmlns="http://s3.amazonaws.com/doc/2006-03-01/"><Name>bucket.storage.l0.mytiki.com</Name><Prefix>2ab3efdb-8e91-4148-a43b-a7c198b4d3d7/KxUsCZPADYumvtpwkMkYILVH8PmX26IbbM_Z-v6cnkE/eBhsjwopFAC3-ybuVUvo2lkIfGLTB4PnPmWKBkUoV4M.block</Prefix><KeyMarker></KeyMarker><VersionIdMarker></VersionIdMarker><MaxKeys>1000</MaxKeys><IsTruncated>false</IsTruncated><Version><Key>2ab3efdb-8e91-4148-a43b-a7c198b4d3d7/KxUsCZPADYumvtpwkMkYILVH8PmX26IbbM_Z-v6cnkE/eBhsjwopFAC3-ybuVUvo2lkIfGLTB4PnPmWKBkUoV4M.block</Key><VersionId>001676493020099746191-49KJ24Grb_</VersionId><IsLatest>true</IsLatest><LastModified>2023-02-15T20:30:20.000Z</LastModified><ETag>&quot;8b063b026bcbfdf321a7d4ff0bc02075&quot;</ETag><Size>1518</Size><Owner><ID>44C1CFE425214F4FFD42464A9DF70766B4723193F144BD7D74DB7190B44A4C03</ID><DisplayName>mike</DisplayName></Owner><StorageClass>STANDARD</StorageClass></Version></ListVersionsResult>';

  Interceptor get pkvInterceptor => nock(StorageRepository.bucketUrl).get(
      '?versions&prefix=2ab3efdb-8e91-4148-a43b-a7c198b4d3d7/KxUsCZPADYumvtpwkMkYILVH8PmX26IbbM_Z-v6cnkE/public.key')
    ..reply(200, utf8.encode(pubKeyVersions));

  Interceptor get listInterceptor => nock(StorageRepository.bucketUrl).get(
      '?prefix=2ab3efdb-8e91-4148-a43b-a7c198b4d3d7/KxUsCZPADYumvtpwkMkYILVH8PmX26IbbM_Z-v6cnkE')
    ..reply(200, utf8.encode(blockList));

  Interceptor get bvInterceptor => nock(StorageRepository.bucketUrl).get(
      '?versions&prefix=2ab3efdb-8e91-4148-a43b-a7c198b4d3d7/KxUsCZPADYumvtpwkMkYILVH8PmX26IbbM_Z-v6cnkE/eBhsjwopFAC3-ybuVUvo2lkIfGLTB4PnPmWKBkUoV4M.block')
    ..reply(200, utf8.encode(blockVersions));

  Interceptor get pkInterceptor =>
      nock(StorageRepository.bucketUrl).get(endsWith('.key'))
        ..query({'versionId': anything})
        ..reply(200, base64.decode(b64PubKey));

  Interceptor get bInterceptor =>
      nock(StorageRepository.bucketUrl).get(endsWith('.block'))
        ..query({'versionId': anything})
        ..reply(200, base64.decode(b64Block));
}
