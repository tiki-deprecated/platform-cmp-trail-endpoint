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
  static const serviceUrl = 'https://storage.l0.mytiki.com';
  static const bucketUrl = 'https://bucket.storage.l0.mytiki.com';

  static const tokenPath = '/api/latest/token';
  static const uploadPath = '/api/latest/upload';

  final Uri _serviceUri = Uri.parse(serviceUrl);
  final Uri _bucketUri = Uri.parse(bucketUrl);

  StorageRepository();

  Future<StorageModelTokenRsp> token(
      String? authorization, StorageModelTokenReq body) async {
    http.Response rsp = await http.post(_serviceUri.replace(path: tokenPath),
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
    http.Response rsp = await http.put(_serviceUri.replace(path: uploadPath),
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

  Future<Uint8List> get(String key, {String? versionId}) async {
    if (key.startsWith('/')) key = key.replaceFirst('/', '');
    http.Response rsp = await http.get(_bucketUri.replace(
      path: key,
      query: versionId != null ? 'versionId=$versionId' : null,
    ));
    if (rsp.statusCode == 200) {
      return rsp.bodyBytes;
    } else {
      throw HttpException('HTTP Error ${rsp.statusCode}: ${rsp.body}');
    }
  }

  Future<StorageModelList> versions(String key) async {
    if (key.startsWith('/')) key = key.replaceFirst('/', '');
    http.Response rsp =
        await http.get(_bucketUri.replace(query: 'versions&prefix=$key'));
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
