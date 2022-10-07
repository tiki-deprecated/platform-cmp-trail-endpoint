import 'package:sqlite3/sqlite3.dart';

import 'consent/consent_service.dart';
import 'node/l0_storage.dart';
import 'node/node_service.dart';
import 'node/node_service_builder.dart';
import 'ownership/ownership_service.dart';
import 'tiki_sdk.dart';

class TikiSdkBuilder {
  late final String _origin;
  late final KeyStorage _keyStorage;
  late final String _databaseDir;

  L0Storage? _l0Storage;
  String? _apiKey;
  String? _address;

  TikiSdkBuilder();

  set origin(String val) => _origin = val;
  set keyStorage(KeyStorage val) => _keyStorage = val;
  set databaseDir(String val) => _databaseDir = val;

  set l0Storage(L0Storage val) => _l0Storage = val;
  set apiKey(String val) => _apiKey = val;
  set address(String val) => _address = val;

  Future<void> build() async {
    NodeServiceBuilder builder = NodeServiceBuilder();
    builder.keyStorage = _keyStorage;
    builder.databaseDir = _databaseDir;
    builder.l0Storage = _l0Storage;
    builder.apiKey = _apiKey;
    builder.address = _address;
    NodeService nodeService = await builder.build();
    OwnershipService ownershipService =
        OwnershipService(_origin, nodeService, builder.database);
    ConsentService consentService =
        ConsentService(builder.database, nodeService);
    TikiSdk tikiSdk = TikiSdk(_origin);
    tikiSdk.nodeService = nodeService;
    tikiSdk.ownershipService = ownershipService;
    tikiSdk.consentService = consentService;
  }
}
