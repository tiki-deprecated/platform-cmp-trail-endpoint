/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:html/parser.dart';
import 'package:http/http.dart' as http;

import '../utils/xml_parse.dart';
import 'sstorage_model_list.dart';
import 'sstorage_model_token_req.dart';
import 'sstorage_model_token_rsp.dart';
import 'sstorage_model_upload.dart';

class SStorageRepository {
  final Uri _serviceUri = Uri(scheme: 'https', host: 'storage.l0.mytiki.com');
  final Uri _bucketUri =
      Uri(scheme: 'https', host: 'bucket.storage.l0.mytiki.com');

  SStorageRepository();

  /// Request a new token to write to the object storage
  ///
  /// When a user wants to write to the object storage, an authentication token
  /// must be requested. To request the token, the user must provide the apiId
  /// that identifies the company that is writing that data in the object storage
  /// and proof of authorship, to make sure that whoever is writing to a specific
  /// address is holding the private key for that address. This can be done by
  /// signing a generic string and sending with the request the signature, the
  /// public key, and the original string. With that information, the server can
  /// verify the signature and make sure that the one trying to create a new
  /// registry in a specific address is the one that holds the private key for
  /// that address.
  Future<SStorageModelTokenRsp> token(
      String? apiId, SStorageModelTokenReq body) async {
    http.Response rsp =
        await http.post(_serviceUri.replace(path: '/api/latest/token'),
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
              "x-api-id": apiId ?? ''
            },
            body: jsonEncode(body.toMap()));
    if (rsp.statusCode == 200) {
      return SStorageModelTokenRsp.fromMap(jsonDecode(rsp.body));
    } else {
      throw HttpException(
          'HTTP Error ${rsp.statusCode}: ${jsonDecode(rsp.body)}');
    }
  }

  Future<void> upload(String? token, SStorageModelUpload body) async {
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

  /// Gets the latest version of an object
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

  /// Gets the all the version of an object, up to 1000.
  Future<SStorageModelList> versions(String path) async {
    if (path.startsWith('/')) path = path.replaceFirst('/', '');
    http.Response rsp =
        await http.get(_bucketUri.replace(query: 'versions&prefix=$path'));
    if (rsp.statusCode == 200) {
      SStorageModelList list = SStorageModelList.fromElement(XmlParse.first(
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
