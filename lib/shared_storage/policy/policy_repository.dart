/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */
/// {@category Node}
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'policy_model_req.dart';
import 'policy_model_rsp.dart';

/// The repository for L0 API access.
class PolicyRepository {
  final Uri _uri = Uri(
      scheme: 'https',
      host: 'storage.l0.mytiki.com',
      path: 'api/latest/policy');
  final Map<String, String> _headers;

  PolicyRepository(String apiId)
      : _headers = {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "x-api-id": apiId
        };

  Future<PolicyModelRsp> policy(PolicyModelReq body) async {
    http.Response rsp = await http.post(_uri,
        headers: _headers, body: jsonEncode(body.toMap()));
    if (rsp.statusCode == 200) {
      return PolicyModelRsp.fromMap(jsonDecode(rsp.body));
    } else {
      throw HttpException(
          'HTTP Error ${rsp.statusCode}: ${jsonDecode(rsp.body)}');
    }
  }
}
