/// The SDK to handle data ownership and consent NFTs with TIKI.
/// {@category SDK}
import 'consent/consent_service.dart';
import 'node/l0_storage.dart';
import 'node/node_service.dart';
import 'ownership/ownership_service.dart';
import 'tiki_sdk.dart';

/// The Builder for the TikiSdk object
class TikiSdkBuilder {
  String? _origin;
  KeyStorage? _keyStorage;
  String? _databaseDir;
  L0Storage? _l0Storage;
  String? _apiKey;
  String? _address;

  /// Sets the default origin for all registries.
  /// 
  /// The defalt origin is the one that will be used as origin for all ownership
  /// assignments that doesn't define different origins. It should follow a 
  /// reversed FQDN syntax. _i.e. com.mycompany.myproduct_
  void origin(String origin) => _origin = origin;
  /// Sets the secure key storage to be used
  void keyStorage(KeyStorage keyStorage) => _keyStorage = keyStorage;
  /// Sets the directory to be used for the database files.
  void databaseDir(String databaseDir) => _databaseDir = databaseDir;
  /// Sets the L0 storage for data backup
  void l0Storage(L0Storage l0Storage) => _l0Storage = l0Storage;
  /// Sets the apiKey to connect to TIKI cloud.
  void apiKey(String? apiKey) => _apiKey = apiKey;
  /// Sets the blockchain address for the private key used in the SDK object.
  void address(String? address) => _address = address;

  Future<TikiSdk> build() async {
    NodeServiceBuilder builder = NodeServiceBuilder()
      ..keyStorage = _keyStorage!
      ..databaseDir = _databaseDir!
      ..l0Storage = _l0Storage
      ..apiKey = _apiKey
      ..address = _address;
    NodeService nodeService = await builder.build();
    OwnershipService ownershipService =
        OwnershipService(_origin!, nodeService, nodeService.database);
    ConsentService consentService =
        ConsentService(nodeService.database, nodeService);
    TikiSdk tikiSdk = TikiSdk()
      ..nodeService = nodeService
      ..ownershipService = ownershipService
      ..consentService = consentService;
    return tikiSdk;
  }
}
