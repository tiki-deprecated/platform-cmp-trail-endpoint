import 'package:sqlite3/sqlite3.dart';

import 'consent/consent_service.dart';
import 'node/l0_storage.dart';
import 'node/node_service.dart';
import 'node/node_service_builder_storage.dart';
import 'ownership/ownership_service.dart';
import 'tiki_sdk.dart';
import 'utils/in_mem_key.dart';

class TikiSdkBuilderStorage {
  late final TikiSdk tikiSdk;
  final String _origin;

  Database? _database;
  KeyStorage? _keyStorage;
  L0Storage? _l0Storage;
  String? _apiKey;
  String? _address;

  TikiSdkBuilderStorage(this._origin) {
    tikiSdk = TikiSdk(_origin);
  }

  set database(Database val) => _database = val;
  set keyStorage(KeyStorage val) => _keyStorage = val;
  set l0Storage(L0Storage val) => _l0Storage = val;
  set apiKey(String val) => _apiKey = val;
  set address(String val) => _address = val;

  Future<void> buildSdk() async {
    if (_l0Storage == null && _apiKey == null) {
      throw Exception(
          'Please provide an apiKey or a L0Storage for chain backup');
    }
    _database ??= sqlite3.openInMemory();
    _keyStorage ??= InMemKeyStorage();
    NodeServiceBuilderStorage builder = NodeServiceBuilderStorage();
    builder.database = _database!;
    builder.keyStorage = _keyStorage!;
    await builder.loadPrimaryKey(_address);
    if (_apiKey != null) {
      builder.loadStorage(_apiKey!);
    } else {
      builder.l0Storage = _l0Storage!;
    }
    NodeService nodeService = await builder.build();
    await nodeService.init();
    OwnershipService ownershipService =
        OwnershipService(_origin, nodeService, _database);
    ConsentService consentService = ConsentService(_database, nodeService);
    tikiSdk.nodeService = nodeService;
    tikiSdk.ownershipService = ownershipService;
    tikiSdk.consentService = consentService;
  }
}
