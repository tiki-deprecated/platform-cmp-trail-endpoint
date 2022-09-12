/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:pointycastle/digests/md5.dart';

import '../../utils/xml.dart' as xml;
import 'wasabi_exception_expired.dart';
import 'wasabi_model_list.dart';

class WasabiRepository {
  static const String _bucket = 'l0-storage-test';
  static const String _region = 'us-central-1';

  final Uri _uri =
      Uri(scheme: 'https', host: '$_bucket.s3.$_region.wasabisys.com');

  Future<Uint8List> get(String path, {String? versionId}) async {
    if (path.startsWith('/')) path = path.replaceFirst('/', '');
    http.Response rsp = await http.get(_uri.replace(
      path: path,
      query: versionId != null ? 'versionId=$versionId' : null,
    ));
    if (rsp.statusCode == 200) {
      return rsp.bodyBytes;
    } else {
      throw HttpException('HTTP Error ${rsp.statusCode}: ${rsp.body}');
    }
  }

  Future<WasabiModelList> versions(String path) async {
    if (path.startsWith('/')) path = path.replaceFirst('/', '');
    http.Response rsp =
        await http.get(_uri.replace(query: 'versions&prefix=$path'));
    if (rsp.statusCode == 200) {
      WasabiModelList list = WasabiModelList.fromElement(xml
          .first(parse(rsp.body).getElementsByTagName('ListVersionsResult')));
      if (list.isTruncated == true) {
        throw UnimplementedError('Version lists > 1000 keys are not supported');
      }
      return list;
    } else {
      throw HttpException('HTTP Error ${rsp.statusCode}: ${rsp.body}');
    }
  }

  Future<String?> upload(
      String path, Map<String, String> fields, Uint8List obj) async {
    if (path.startsWith('/')) path = path.replaceFirst('/', '');
    http.MultipartRequest request = http.MultipartRequest('POST', _uri);
    request.fields.addAll(fields);
    request.fields["content-md5"] = base64.encode(MD5Digest().process(obj));
    request.fields['key'] = path;
    request.files.add(http.MultipartFile.fromBytes('file', obj));
    http.StreamedResponse rsp = await request.send();
    if (rsp.statusCode == 204) {
      return rsp.headers['x-amz-version-id'];
    } else {
      String body = await rsp.stream.bytesToString();
      if (body.contains('Policy expired')) {
        throw WasabiExceptionExpired(body);
      } else {
        throw HttpException('HTTP Error ${rsp.statusCode}: $body');
      }
    }
  }
}
