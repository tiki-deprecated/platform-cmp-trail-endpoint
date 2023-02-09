/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:html/parser.dart';
import 'package:http/http.dart' as http;

import '../../utils/xml_parse.dart';
import 'storage_model_list.dart';
import 'storage_model_token_req.dart';
import 'storage_model_token_rsp.dart';
import 'storage_model_upload.dart';

class StorageRepository {
  final Uri _serviceUri = Uri(scheme: 'https', host: 'storage.l0.mytiki.com');
  final Uri _bucketUri =
      Uri(scheme: 'https', host: 'bucket.storage.l0.mytiki.com');

  StorageRepository();

  Future<StorageModelTokenRsp> token(
      String? authorization, StorageModelTokenReq body) async {
    http.Response rsp =
        await http.post(_serviceUri.replace(path: '/api/latest/token'),
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
              "Authorization": "Bearer ${authorization ?? ''}"
            },
            body: jsonEncode(body.toMap()));
    if (rsp.statusCode == 200) {
      return StorageModelTokenRsp.fromMap(jsonDecode(rsp.body));
    } else {
      throw HttpException(
          'HTTP Error ${rsp.statusCode}: ${jsonDecode(rsp.body)}');
    }
  }

  Future<void> upload(String? token, StorageModelUpload body) async {
    http.Response rsp =
        await http.put(_serviceUri.replace(path: '/api/latest/upload'),
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
              "Authorization": "Bearer $token"
            },
            body: jsonEncode(body.toMap()));
    if (rsp.statusCode != 201) {
      throw HttpException(
          'HTTP Error ${rsp.statusCode}: ${jsonDecode(rsp.body)}');
    }
  }

  Future<Uint8List> get(String path, {String? versionId}) async {
    if (path.startsWith('/')) path = path.replaceFirst('/', '');
    http.Response rsp = await http.get(_bucketUri.replace(
      path: path,
      query: versionId != null ? 'versionId=$versionId' : null,
    ));
    if (rsp.statusCode == 200) {
      return rsp.bodyBytes;
    } else {
      throw HttpException('HTTP Error ${rsp.statusCode}: ${rsp.body}');
    }
  }

  Future<StorageModelList> versions(String path) async {
    if (path.startsWith('/')) path = path.replaceFirst('/', '');
    http.Response rsp =
        await http.get(_bucketUri.replace(query: 'versions&prefix=$path'));
    if (rsp.statusCode == 200) {
      StorageModelList list = StorageModelList.fromElement(XmlParse.first(
          parse(rsp.body).getElementsByTagName('ListVersionsResult')));
      if (list.isTruncated == true) {
        throw UnimplementedError('Version lists > 1000 keys are not supported');
      }
      return list;
    } else {
      throw HttpException('HTTP Error ${rsp.statusCode}: ${rsp.body}');
    }
  }
}
