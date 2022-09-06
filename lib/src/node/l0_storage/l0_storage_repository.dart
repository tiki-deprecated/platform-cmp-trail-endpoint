/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';

import 'package:http/http.dart' as http;

import 'l0_storage_model_policy_req.dart';
import 'l0_storage_model_policy_rsp.dart';

class L0StorageRepository {
  final Uri _uri = Uri(
      scheme: 'https',
      host: 'storage.l0.mytiki.com',
      path: 'api/latest/policy');
  final Map<String, String> _headers;

  L0StorageRepository(String apiId)
      : _headers = {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "x-api-id": apiId
        };

  Future<L0StorageModelPolicyRsp?> policy(L0StorageModelPolicyReq body,
      {Function(http.Response)? onFailure}) async {
    http.Response rsp = await http.post(_uri,
        headers: _headers, body: jsonEncode(body.toMap()));
    if (rsp.statusCode == 200) {
      return L0StorageModelPolicyRsp.fromMap(jsonDecode(rsp.body));
    } else if (onFailure != null) {
      return onFailure(rsp);
    }
  }
}
