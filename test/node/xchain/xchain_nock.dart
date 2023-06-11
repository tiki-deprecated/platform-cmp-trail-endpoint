/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';

import 'package:nock/nock.dart';
import 'package:test/expect.dart';
import 'package:tiki_trail/l0/storage/storage_repository.dart';

class XChainNock {
  String appId = '2ab3efdb-8e91-4148-a43b-a7c198b4d3d7';
  String address = 'FaUMg5tkhk898KgcWwK6MVbCAiYaE-v_qh0tJwSru5I';

  String b64Block =
      '/QABXls2NTisiN4L/WatCwSBgdLJzy7Z0xF0IuyfT4VPo/cafXOdJGFCQruzpalO+QKNJoVOLt4SowvvsXTIeXTAO2xxiMJG5TEr1yUDodawd3sqzhD1Ske3k6aOHaeDnRZsCQocQr0jP9/8eTmusEmNRRkw1oIVvaEJseXgFbRk3iZ+8l9Iu/JO2lT84pHDlVZsP/Do/t/7jqk9o3/eOXNEhOhqNEWe6f/CgjwGnJHqELtqptRUQYjT7zsfVpIEqKBLsPtqVJlEWlRrqY5dEqLA/kdX6rnbadvz6on5HzUOTQWZRaN7jEWHW6gunhRTb9lV8xPcGCNjg7ie5BhHf176cP0kAgEBBGQNUt0gXO99p1jVEfpQoSnGnLy42h0NXgoDXJ428CaEI9p9ZtYg1CQMYKYtO9Bt2DnexUWNL3gSvs6kPKIxY84gYovUJM4BAf3WAQECIBWlDIObZIZPPfCoHFsCujFWwgImGhPr/6odLScEq7uSBGQNUt0xdHhuOi8vNFFsSUh3TVpZamNGdjVabU9Sc1R4WHlaTE9PZm1pU1VVYjVNZ0NqZHJVRf0AAUDusvurofCiXOLvtQAFjkuJrq9haVG+DMtZmA7BtznbeDovnyGcSTvzKmfQzQuv2NRXOvxZ2q4dOP+/uRypq/tbE/g/GkMhZ5uNS6Kd0wbR+LX7BWUhzf6zvmyeSAkcK3aicIQWm1vSt+X+MfK1ptdaASRQzQjVXfktQzbeAlZRPw0SO+hZ2tSU0atHaBvEz7d2OBVuV++2gfoWWcG2TnAwntr2FMbwmU9ny2BDpI0d0JHvv4gq11EjgzyfK5B1QNa4H9okWFaTfR9yl+kQE+CHEnTzmZbFqxe8oVw6ZSai0B6kY1ujmQUoN7P90yeHpG5K7sYWceyroFoburBQHvUAdwEDRFt7InVzZWNhc2VzIjpbImN1c3RvbTp0ZXN0aW5nIl0sImRlc3RpbmF0aW9ucyI6WyJcXC5teXRpa2lcXC5jb20iXX1dGGZvciB1c2UgaW4gdGVzdGluZyBvbmx5LhFyZWdpc3RyeSB0ZXN0aW5nLgRkDqRd';
  String b64PubKey =
      'MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAyrcrTS348ctEjMgk8D2Z3QJSmBTWaPdwU1qMu7f7co5e55MG0HYg5spskoBy7EWcupB+G5qxK+VmvWLpRh/ktoniwi9CrGYu2tZo08IVCDoNhNLOfS5RqnkDnKOVJRl3evoIcVJZdIYOqIk9e9hzB+DswLWSFeOOXDO38WFs+4jJaMhe4CfA9stlXS44a3iNtZa52idev4M+FytbqEELQpSJhKp2FLp6dDQNj+ZUO+mwAW/wFTRMiwXwjLXGusQ3Q69OlkfyJ5yOxwSJhXXl5A/hmdWOwGsaxiOfY4kys0kz7zg5O2KXWG/9plPoEoPCf0joFKrtMp27F214F9SM8QIDAQAB';
  String pubKeyVersions =
      '<?xml version="1.0" encoding="UTF-8"?><ListVersionsResult xmlns="http://s3.amazonaws.com/doc/2006-03-01/"><Name>bucket.storage.l0.mytiki.com</Name><Prefix>2ab3efdb-8e91-4148-a43b-a7c198b4d3d7/FaUMg5tkhk898KgcWwK6MVbCAiYaE-v_qh0tJwSru5I/public.key</Prefix><KeyMarker></KeyMarker><VersionIdMarker></VersionIdMarker><MaxKeys>1000</MaxKeys><IsTruncated>false</IsTruncated><Version><Key>2ab3efdb-8e91-4148-a43b-a7c198b4d3d7/FaUMg5tkhk898KgcWwK6MVbCAiYaE-v_qh0tJwSru5I/public.key</Key><VersionId>001678594770904748508-rQRNNSwrAe</VersionId><IsLatest>true</IsLatest><LastModified>2023-03-12T04:19:31.000Z</LastModified><ETag>&quot;f96d514eecbdf43f184481cd01dab0d1&quot;</ETag><Size>294</Size><Owner><ID>44C1CFE425214F4FFD42464A9DF70766B4723193F144BD7D74DB7190B44A4C03</ID><DisplayName>mike</DisplayName></Owner><StorageClass>STANDARD</StorageClass></Version></ListVersionsResult>';
  String blockList =
      '<?xml version="1.0" encoding="UTF-8"?> <ListBucketResult xmlns="http://s3.amazonaws.com/doc/2006-03-01/"> <Name>bucket.storage.l0.mytiki.com</Name> <Prefix>2ab3efdb-8e91-4148-a43b-a7c198b4d3d7/FaUMg5tkhk898KgcWwK6MVbCAiYaE-v_qh0tJwSru5I</Prefix> <Marker></Marker> <MaxKeys>1000</MaxKeys> <IsTruncated>false</IsTruncated> <Contents> <Key>2ab3efdb-8e91-4148-a43b-a7c198b4d3d7/FaUMg5tkhk898KgcWwK6MVbCAiYaE-v_qh0tJwSru5I/2jPH00bX27QFlbJDynobsTHMQ71_kVWJbKVbuJMGTYI.block</Key> <LastModified>2023-03-12T04:19:42.000Z</LastModified> <ETag>&quot;2f78df08a19118a898d33c58d5d526c4&quot;</ETag> <Size>810</Size> <Owner> <ID>44C1CFE425214F4FFD42464A9DF70766B4723193F144BD7D74DB7190B44A4C03</ID> <DisplayName>mike</DisplayName> </Owner> <StorageClass>STANDARD</StorageClass> </Contents> </ListBucketResult>';
  String blockVersions =
      '<?xml version="1.0" encoding="UTF-8"?><ListVersionsResult xmlns="http://s3.amazonaws.com/doc/2006-03-01/"><Name>bucket.storage.l0.mytiki.com</Name><Prefix>2ab3efdb-8e91-4148-a43b-a7c198b4d3d7/FaUMg5tkhk898KgcWwK6MVbCAiYaE-v_qh0tJwSru5I/z3h5zf--SSmif0Dd-iTEpr-fxX2bBMpD4DzP0reOchk.block</Prefix><KeyMarker></KeyMarker><VersionIdMarker></VersionIdMarker><MaxKeys>1000</MaxKeys><IsTruncated>false</IsTruncated><Version><Key>2ab3efdb-8e91-4148-a43b-a7c198b4d3d7/xsKfWczVl24doWj_GWeJ__7EKOdrJ-Ryh64b_IrJlUM/z3h5zf--SSmif0Dd-iTEpr-fxX2bBMpD4DzP0reOchk.block</Key><VersionId>001678595203449176579-UYPrPWX3Yr</VersionId><IsLatest>true</IsLatest><LastModified>2023-03-12T04:26:43.000Z</LastModified><ETag>&quot;6227993416d340561d65dec0f93a9eb1&quot;</ETag><Size>695</Size><Owner><ID>44C1CFE425214F4FFD42464A9DF70766B4723193F144BD7D74DB7190B44A4C03</ID><DisplayName>mike</DisplayName></Owner><StorageClass>STANDARD</StorageClass></Version><Version><Key>2ab3efdb-8e91-4148-a43b-a7c198b4d3d7/xsKfWczVl24doWj_GWeJ__7EKOdrJ-Ryh64b_IrJlUM/z3h5zf--SSmif0Dd-iTEpr-fxX2bBMpD4DzP0reOchk.block</Key><VersionId>001678595203404733909-VNZhCyeoQo</VersionId><IsLatest>false</IsLatest><LastModified>2023-03-12T04:26:43.000Z</LastModified><ETag>&quot;6227993416d340561d65dec0f93a9eb1&quot;</ETag><Size>695</Size><Owner><ID>44C1CFE425214F4FFD42464A9DF70766B4723193F144BD7D74DB7190B44A4C03</ID><DisplayName>mike</DisplayName></Owner><StorageClass>STANDARD</StorageClass></Version></ListVersionsResult>';

  Interceptor get pkvInterceptor => nock(StorageRepository.bucketUrl)
      .get('?versions&prefix=$appId/$address/public.key')
    ..reply(200, utf8.encode(pubKeyVersions));

  Interceptor get listInterceptor =>
      nock(StorageRepository.bucketUrl).get('?prefix=$appId/$address')
        ..reply(200, utf8.encode(blockList));

  Interceptor get bvInterceptor => nock(StorageRepository.bucketUrl).get(
      '?versions&prefix=$appId/$address/2jPH00bX27QFlbJDynobsTHMQ71_kVWJbKVbuJMGTYI.block')
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
