/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

library tiki_sdk_dart;

import 'package:sqlite3/common.dart';

import 'cache/license/license_service.dart';
import 'cache/title/title_service.dart';
import 'l0/storage/storage_service.dart';
import 'license_record.dart';
import 'node/backup/backup_service.dart';
import 'node/block/block_service.dart';
import 'node/key/key_service.dart';
import 'node/node_service.dart';
import 'node/transaction/transaction_service.dart';
import 'title_record.dart';
import 'utils/bytes.dart';

export 'cache/license/license_use.dart';
export 'cache/license/license_usecase.dart';
export 'cache/title/title_tag.dart';
export 'license_record.dart';
export 'node/key/key_storage.dart';
export 'title_record.dart';

class TikiSdk {
  final TitleService _titleService;
  final LicenseService _licenseService;
  final NodeService _nodeService;

  /// Recommended to use [withAddress] and [init] instead.
  TikiSdk(TitleService titleService, LicenseService licenseService,
      NodeService nodeService)
      : _titleService = titleService,
        _licenseService = licenseService,
        _nodeService = nodeService;

  static Future<String> withAddress(KeyStorage keyStorage,
      {String? address}) async {
    KeyService keyService = KeyService(keyStorage);
    KeyModel primaryKey = address != null
        ? await keyService.get(address) ??
            await keyService.create() //should print warning about this!?
        : await keyService.create();
    return Bytes.base64UrlEncode(primaryKey.address);
  }

  static Future<TikiSdk> init(String publishingId, String orign,
      KeyStorage keyStorage, String address, CommonDatabase database) async {
    KeyService keyService = KeyService(keyStorage);
    KeyModel? primaryKey = await keyService.get(address);
    if (primaryKey == null) {
      throw StateError("Use keystore() to initialize address");
    }

    StorageService l0Storage =
        StorageService.publishingId(primaryKey.privateKey, publishingId);
    NodeService nodeService = NodeService()
      ..blockInterval = const Duration(minutes: 1)
      ..maxTransactions = 200
      ..transactionService = TransactionService(database)
      ..blockService = BlockService(database)
      ..primaryKey = primaryKey;
    nodeService.backupService =
        BackupService(l0Storage, database, primaryKey, nodeService.getBlock);
    await nodeService.init();

    TitleService titleService =
        TitleService(orign, nodeService, nodeService.database);
    LicenseService licenseService =
        LicenseService(nodeService.database, nodeService);
    return TikiSdk(titleService, licenseService, nodeService);
  }

  String get address => _nodeService.address;

  Future<LicenseRecord> license(String ptr, List<LicenseUse> uses, String terms,
      {String? origin,
      List<TitleTag> tags = const [],
      String? titleDescription,
      String? licenseDescription,
      DateTime? expiry}) async {
    TitleModel? title = _titleService.getByPtr(ptr, origin: origin);
    title ??= await _titleService.create(ptr,
        origin: origin, tags: tags, description: titleDescription);
    LicenseModel license = await _licenseService.create(
        title.transactionId!, uses, terms,
        description: licenseDescription, expiry: expiry);
    return _toLicense(title, license);
  }

  Future<TitleRecord> title(String ptr,
      {String? origin,
      List<TitleTag> tags = const [],
      String? description}) async {
    TitleModel title = await _titleService.create(ptr,
        origin: origin, description: description, tags: tags);
    return TitleRecord(Bytes.base64UrlEncode(title.transactionId!), title.ptr,
        origin: title.origin, tags: title.tags, description: title.description);
  }

  LicenseRecord? latest(String ptr, {String? origin}) {
    TitleModel? title = _titleService.getByPtr(ptr, origin: origin);
    if (title == null) return null;
    LicenseModel? license = _licenseService.getLatest(title.transactionId!);
    if (license == null) return null;
    return _toLicense(title, license);
  }

  List<LicenseRecord> all(String ptr, {String? origin}) {
    TitleModel? title = _titleService.getByPtr(ptr, origin: origin);
    if (title == null) return [];
    List<LicenseModel> licenses = _licenseService.getAll(title.transactionId!);
    return licenses.map((license) => _toLicense(title, license)).toList();
  }

  LicenseRecord? getLicense(String id) {
    LicenseModel? license = _licenseService.getById(Bytes.base64UrlDecode(id));
    if (license == null) return null;
    TitleModel? title = _titleService.getById(license.title);
    if (title == null) return null;
    return _toLicense(title, license);
  }

  TitleRecord? getTitle(String id) {
    TitleModel? model = _titleService.getById(Bytes.base64UrlDecode(id));
    if (model == null) return null;
    return TitleRecord(id, model.ptr,
        origin: model.origin, tags: model.tags, description: model.description);
  }

  bool guard(String ptr, List<LicenseUse> uses, {String? origin}) {
    throw UnimplementedError("WIP. Not ready yet.");
  }

  LicenseRecord _toLicense(
          TitleModel title, LicenseModel license) =>
      LicenseRecord(
          Bytes.base64UrlEncode(license.transactionId!),
          TitleRecord(Bytes.base64UrlEncode(title.transactionId!), title.ptr,
              origin: title.origin,
              tags: title.tags,
              description: title.description),
          license.uses,
          license.terms,
          description: license.description,
          expiry: license.expiry);
}

//old docs here for ref.

/// The SDK to handle data ownership and consent NFTs with TIKI.
///
/// ## Initialization
///
/// To initialize the TIKI SDK, use the [TikiSdkBuilder].
///
/// ```
/// TikiSdk tiki = await (TikiSdkBuilder()
///   ..origin('com.mycompany.myproduct')
///   ..databaseDir('/')
///   ..apiKey('565b3268-cdc0-4e5c-94c8-5d8f53d4577c')
///   ..keyStorage(MyKeyStorageImpl()))
///   .build();
/// ```
/// Check [TikiSdkBuilder] documentation for a detailed description of the paramenters.
///
/// ## Assign Ownership
///
/// The assignOwnership method creates a way to prove ownership of a specific
/// piece of data. This is an important first step when working with TikiSdk
/// because ownership must be established for a data source before it can be
/// used and user consent can be requested.
///
/// To establish ownership, the method generates a unique digital token called
/// an Ownership NFT. This token identifies the owner of a piece of data from a
/// source and specifies the type of data (identified with TikiSdkDataTypeEnum)
/// and the items it contains. Additional information like a description can be
/// added using the about parameter and an override for the default origin can
/// be specified.
///
/// The method returns an identifier called ownershipId that uniquely identifies
/// the Ownership NFT stored in the blockchain. This identifier is required to
/// request consent from the user to use the data source associated with this
/// ownership.
///
/// ```
/// String ownershipId = tikiSdk.assignOwnership(
///   <String source>,
///   <TikiSdkDataTypeEnum type>,
///   <List<String> contains>,
///   about: <String? about>,
///   origin: <String? origin>});
/// ```
///
/// ## Give Consent
///
/// After establishing the ownership of the data source, the ``modifyConsent` method
/// can be used to change the user's consent settings for data usage.
///
/// The user's consent for data usage is stored in a Consent NFT, which identifies
/// the user's current decision on the usage of the source data. At any time,
/// the user can change their consent by creating a new NFT.
///
/// By default, all requests for data usage will be denied unless they are
/// explicitly defined in the destination parameter. If consent has been revoked,
/// the `TikiSdkDestination.uses` and `TikiSdkDestination.paths` lists will be empty.
///
/// Additional information also can be provided like a description of the consent
/// modification using the optional `about` parameter, and specify any compensation
/// being offered for consent with the optional `reward` parameter.
/// Additionally, an optional expiration date for the consent can be set using
/// the `expiry` parameter.
///
/// This method returns the modified ConsentModel that represents the latest
/// Consent NFT.
///
/// ```
/// ConsentModel consent = tikiSdk.modifyConsent(
///   ownershipId, destination, about: about, reward: reward, expiry: expiry);
/// ```
/// ## Get Consent
///
/// The user's current consent is stored in a Consent NFT, and the `getConsent`
/// method retrieves the latest consent model for a data source.
///
/// It is important to note that the consent model returned by `getConsent` may
/// be expired or not applicable to a specific destination. To ensure that the
/// consent is valid for a specific usage, the `applyConsent` method should be
/// used instead.
///
/// ```
/// ConsentModel consent = tikiSdk. getConsent(source, origin: origin);
/// ```
///
/// ## Revoke Consent
///
/// If a user wants to revoke their previously given consent for a data source,
/// the constant TikiSdkDestition.none() should be used. This constant represents
/// an empty destination object that does not allow any usage of the data source,
/// effectively revoking the user's consent.
///
/// When the modifyConsent method is called with TikiSdkDestition.none(), a new
/// Consent NFT will be created without any destination approval. This means that
/// the user does not allow the usage of the data source anywhere, revoking any
/// prior consent.
/// ```
/// ConsentModel consent = tikiSdk.modifyConsent(ownershipId, TikiSdkDestination.none());
/// ```
///
/// ## Apply Consent
///
/// The `applyConsent` method is used to verify the user consent for a specified
/// data source and destination, by executing a request if valid consent exists.
/// If no valid consent exists, the function calls the onBlocked callback function,
/// passing a message that provides information on why the request was blocked.
/// This function takes four parameters: the data source, the destination object,
/// the request function to execute, and an optional onBlocked callback function
/// to call if the request is blocked. This function receives the reason of the
/// request been blocked or the transaction Id for the Consent NFT that blocked it.
/// Additionally, an optional origin parameter can be passed to specify the data
/// source's origin.
///
/// The function returns a Future that resolves when the request is completed.
/// ```
/// Function request = () => print('ok');
/// Function onBlocked = (_) => print('blocked');
/// tikiSdk.applyConsent(source, destination, request, onBlocked: onBlocked);
/// ```
///
/// API Reference
/// -------------
///
/// ### TikiSdkDataTypeEnum
///
/// The `TikiSdkDataTypeEnum` specifies the type of data to which the ownership refers.
///
/// Values:
///
/// *   `data_point`: A specific and single occurrence of a data.
/// *   `data_pool`: A pool of data from different occurrences.
/// *   `data_stream`: A continuous stream of data.
///
/// ### TikiSdkDestination
///
/// The `TikiSdkDestination` specifies the destination to which the data is consented
/// to be used. It is composed of two components, `uses` and `paths`.
///
/// To allow all destinations, use `TikiSdkDestination.all()`. To block all destinations,
/// use `TikiSdkDestination.none()`.
///
/// #### uses
///
/// An optional list of application-specific use cases applicable to the given
/// destination. The list can be inverted by prefixing it with "NOT". For example,
/// "NOT ads" would exclude "ads" from the list.
///
/// #### paths
///
/// A list of paths, preferably URL without the scheme or reverse-DNS. Keep the
/// list short and use wildcard (_) matching. The list can be inverted by prefixing
/// it with "NOT". For example, "NOT mytiki.com/_" would exclude "mytiki.com" and
/// its subdomains from the list.
///
/// #### Wildcards
///
/// Wildcards are allowed in both `uses` and `paths` using `*`. To allow all
/// uses, use a single item list with `*`. To block all uses, create an empty list.
