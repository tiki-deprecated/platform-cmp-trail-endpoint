/// The SDK to handle data ownership and consent NFTs with TIKI.
import 'package:sqlite3/sqlite3.dart';

import 'consent/consent_service.dart';
import 'node/node_service.dart';
import 'ownership/ownership_service.dart';
import 'tiki_sdk.dart';

/// # The Builder for the TikiSdk object
///
/// ## How to use
///
/// ### 1 - Initialize the builder
///
/// ```
///   TikiSdkBuilder builder = TikiSdkBuilder();
/// ```
///
/// ### 2 - Set the default Origin
///
/// The default origin is the one that will be used as origin for all ownership assignments that doesn't define different origins. It should follow a reversed FQDN syntax. _i.e. com.mycompany.myproduct_
///
/// ```
/// builder.origin('com.mycompany.myproduct');
/// ```
///
/// ### 3 - Set the Database Directory
///
/// TIKI SDK uses SQLite for local database caching. This directory defines where the database files will be stored.
///
/// ```
/// builder.databaseDir('path/to/database')
/// ```
///
/// ### 4 - Set the storage for user`s private key
/// The user private key is sensitive information and should be kept in a secure and encrypted key-value storage. It should use an implementation of the `KeyStorage` interface,
/// ```
/// builder.keyStorage = InMemKeyStorage();
/// ```
///
/// **DO NOT USE InMemKeyStorage in production.**
/// ### 5 - Set the API key for connection with TIKI Cloud
/// Create your API key in [mytiki.com](mytiki.com)
/// ```
/// builder.apiKey = "api_key_from_mytiki.com";
/// ```
///
/// ### 6 - address
/// Set the user address. If it is not set, a new private key will be created for the user.
/// ```
/// builder.apiKey = "api_key_from_mytiki.com";
/// ```
/// ### 7 - Build it!
/// After setting all the properties for the builder, build it to use.
/// ```
/// TikiSdk sdk = builder.build();
/// ```
class TikiSdkBuilder {
  String? _origin;
  KeyStorage? _keyStorage;
  String? _databaseDir;
  String? _publishingId;
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

  /// Sets the apiKey to connect to TIKI cloud.
  void publishingId(String? publishingId) => _publishingId = publishingId;

  /// Sets the blockchain address for the private key used in the SDK object.
  void address(String? address) => _address = address;

  /// Builds the [TikiSdk] object.
  ///
  /// This method should only be called after setting [keyStorage] and [databaseDir].
  /// An error will be thrown if one of them is not set
  Future<TikiSdk> build() async {
    KeyModel primaryKey = await _loadPrimaryKey();
    Database database = sqlite3
        .open("$_databaseDir/${Bytes.base64UrlEncode(primaryKey.address)}.db");

    BackupClient backupClient =
        SStorageService(_publishingId!, primaryKey.privateKey); //TODO fix

    NodeService nodeService = NodeService()
      ..blockInterval = const Duration(minutes: 1)
      ..maxTransactions = 200
      ..transactionService = TransactionService(database)
      ..blockService = BlockService(database)
      ..primaryKey = primaryKey;
    nodeService.backupService =
        BackupService(backupClient, database, primaryKey, nodeService.getBlock);
    await nodeService.init();

    OwnershipService ownershipService =
        OwnershipService(_origin!, nodeService, nodeService.database);
    ConsentService consentService =
        ConsentService(nodeService.database, nodeService);
    return TikiSdk(ownershipService, consentService, nodeService);
  }

  Future<KeyModel> _loadPrimaryKey() async {
    if (_keyStorage == null) {
      throw Exception('Keystore must be set to build NodeService');
    }
    KeyService keyService = KeyService(_keyStorage!);
    if (_address != null) {
      KeyModel? key = await keyService.get(_address!);
      if (key != null) {
        return key;
      }
    }
    return await keyService.create();
  }
}
