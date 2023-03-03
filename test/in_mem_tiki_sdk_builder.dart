/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:tiki_sdk_dart/cache/license/license_service.dart';
import 'package:tiki_sdk_dart/cache/title/title_service.dart';
import 'package:tiki_sdk_dart/node/node_service.dart';
import 'package:tiki_sdk_dart/tiki_sdk.dart';

import 'in_mem_node_service_builder.dart';

class InMemTikiSdkBuilder {
  String? _origin;
  String? _address;
  InMemNodeServiceBuilder nodeServiceBuilder = InMemNodeServiceBuilder();

  void origin(String origin) => _origin = origin;
  void address(String? address) => _address = address;

  Future<TikiSdk> build() async {
    nodeServiceBuilder.address = _address;
    NodeService nodeService = await nodeServiceBuilder.build();
    TitleService titleService =
        TitleService(_origin!, nodeService, nodeService.database);
    LicenseService licenseService =
        LicenseService(nodeService.database, nodeService);
    return TikiSdk(titleService, licenseService, nodeService);
  }
}
