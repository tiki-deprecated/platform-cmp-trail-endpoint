import 'package:tiki_sdk_dart/consent/consent_service.dart';
import 'package:tiki_sdk_dart/node/node_service.dart';
import 'package:tiki_sdk_dart/ownership/ownership_service.dart';
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
    OwnershipService ownershipService =
        OwnershipService(_origin!, nodeService, nodeService.database);
    ConsentService consentService =
        ConsentService(nodeService.database, nodeService);
    return TikiSdk(ownershipService, consentService, nodeService);
  }
}
