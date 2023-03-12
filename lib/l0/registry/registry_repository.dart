/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'registry_model_req.dart';
import 'registry_model_rsp.dart';

class RegistryRepository {
  static const url = 'https://registry.l0.mytiki.com';
  static const String path = '/api/latest/id';
  static const String headerSignature = 'X-Address-Signature';
  static const String headerCustomerAuth = 'X-Customer-Authorization';

  final Uri _serviceUri = Uri.parse('$url$path');

  Future<RegistryModelRsp> register(RegistryModelReq req,
      {String? signature, String? authorization, String? customerAuth}) async {
    http.Response rsp = await http.post(_serviceUri,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $authorization",
          headerSignature: signature ?? "",
          headerCustomerAuth: "Bearer $customerAuth",
        },
        body: jsonEncode(req.toMap()));
    if (rsp.statusCode == 200) {
      return RegistryModelRsp.fromMap(jsonDecode(rsp.body));
    } else {
      throw HttpException(
          'HTTP Error ${rsp.statusCode}: ${jsonDecode(rsp.body)}');
    }
  }

  Future<RegistryModelRsp> addresses(String id,
      {String? signature, String? authorization, String? customerAuth}) async {
    http.Response rsp = await http
        .get(_serviceUri.replace(path: '$path/$id/addresses'), headers: {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $authorization",
      headerSignature: signature ?? "",
      headerCustomerAuth: "Bearer $customerAuth",
    });
    if (rsp.statusCode == 200) {
      return RegistryModelRsp.fromMap(jsonDecode(rsp.body));
    } else {
      throw HttpException(
          'HTTP Error ${rsp.statusCode}: ${jsonDecode(rsp.body)}');
    }
  }
}
