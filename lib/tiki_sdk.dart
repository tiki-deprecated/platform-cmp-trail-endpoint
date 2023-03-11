/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */
library tiki_sdk_dart;

import 'dart:typed_data';

import 'package:sqlite3/common.dart';
import 'package:tiki_sdk_dart/utils/compact_size.dart';

import 'cache/content_schema.dart';
import 'cache/license/license_model.dart';
import 'cache/license/license_service.dart';
import 'cache/license/license_use.dart';
import 'cache/license/license_usecase.dart';
import 'cache/title/title_model.dart';
import 'cache/title/title_service.dart';
import 'cache/title/title_tag.dart';
import 'guard.dart';
import 'l0/auth/auth_service.dart';
import 'l0/registry/registry_service.dart';
import 'l0/storage/storage_service.dart';
import 'license_record.dart';
import 'node/backup/backup_service.dart';
import 'node/block/block_service.dart';
import 'node/key/key_model.dart';
import 'node/key/key_service.dart';
import 'node/key/key_storage.dart';
import 'node/node_service.dart';
import 'node/transaction/transaction_service.dart';
import 'node/xchain/xchain_service.dart';
import 'title_record.dart';
import 'utils/bytes.dart';

export 'cache/license/license_use.dart';
export 'cache/license/license_usecase.dart';
export 'cache/title/title_tag.dart';
export 'license_record.dart';
export 'node/key/key_storage.dart';
export 'title_record.dart';

/// The primary class for the tiki_sdk_dart library.
/// Use this to create, get, and enforce [LicenseRecord]s and
/// [TitleRecord]s.
class TikiSdk {
  final RegistryService _registryService;
  final TitleService _titleService;
  final LicenseService _licenseService;
  final NodeService _nodeService;

  /// Prefer [withAddress] and [init] instead.
  /// @nodoc
  TikiSdk(TitleService titleService, LicenseService licenseService,
      NodeService nodeService, RegistryService registryService)
      : _titleService = titleService,
        _licenseService = licenseService,
        _nodeService = nodeService,
        _registryService = registryService {
    _syncRegistry();
  }

  /// Use before [init] to add a wallet address and keypair
  /// to the [keyStorage] for [id].
  ///
  /// If the private keys are missing a new address and
  /// private key is created.
  ///
  /// Returns the valid (created or provided) address
  static Future<String> withId(String id, KeyStorage keyStorage) async {
    KeyService keyService = KeyService(keyStorage);
    KeyModel primaryKey =
        await keyService.get(id) ?? await keyService.create(id: id);
    return Bytes.base64UrlEncode(primaryKey.address);
  }

  /// Returns a new initialized [TikiSdk] instance.
  ///
  /// Parameters:
  ///
  /// • [publishingId] - Sign up for a free developer account
  /// at https://console.mytiki.com to get a Publishing ID.
  ///
  /// • [origin] - The default origin to use during [TitleRecord] creation.
  /// Follow a reverse-DNS syntax. _i.e. com.myco.myapp_
  ///
  /// • [keyStorage] - Platform-specific, encrypted, private key persistence.
  ///
  /// • [id] - The id mapped to the wallet's address and private keys.
  /// Private key MUST be previously registered in the provided [keyStorage].
  /// Use [withId].
  ///
  /// • [database] - Platform-specific sqlite3 implementation, opened.
  static Future<TikiSdk> init(String publishingId, String origin,
      KeyStorage keyStorage, String id, CommonDatabase database,
      {int maxTransactions = 1,
      Duration blockInterval = const Duration(minutes: 1)}) async {
    KeyService keyService = KeyService(keyStorage);
    KeyModel? primaryKey = await keyService.get(id);
    if (primaryKey == null) {
      throw StateError("Use keystore() to initialize address");
    }

    AuthService authService = AuthService(publishingId);
    StorageService storageService =
        StorageService(primaryKey.privateKey, authService);

    NodeService nodeService = NodeService()
      ..blockInterval = blockInterval
      ..maxTransactions = maxTransactions
      ..transactionService = TransactionService(database)
      ..blockService = BlockService(database)
      ..xChainService = XChainService(storageService, database)
      ..primaryKey = primaryKey;
    nodeService.backupService = BackupService(
        storageService, database, primaryKey, nodeService.getBlock);
    await nodeService.init();

    TitleService titleService =
        TitleService(origin, nodeService, nodeService.database);
    LicenseService licenseService =
        LicenseService(nodeService.database, nodeService);
    RegistryService registryService =
        RegistryService(primaryKey.privateKey, authService);
    await registryService.register(id, nodeService.address);

    return TikiSdk(titleService, licenseService, nodeService, registryService);
  }

  /// Returns the in-use wallet [address].
  ///
  /// Refers to the blockchain wallet address currently in use by this [TikiSdk]
  /// instance. This [address] serves as a unique identifier for a particular
  /// combination of user and device. If either the user or the device changes,
  /// use a a different [address].
  ///
  /// After [init], store the address somewhere local to your app that
  /// you can easily retrieve and reuse on app-reload.
  String get address => _nodeService.address;

  String get id => _nodeService.id;

  /// Create a new [LicenseRecord].
  ///
  /// If a [TitleRecord] for the [ptr] and [origin] is not found. A new
  /// [TitleRecord] is created. If a [TitleRecord] is found, [tags] and
  /// [titleDescription] parameters are ignored.
  ///
  /// Parameters:
  ///
  /// • [ptr] - The Pointer Records identifies data stored in your system,
  /// similar to a foreign key.
  /// [Learn more](https://docs.mytiki.com/docs/selecting-a-pointer-record)
  /// about selecting good pointer records.
  ///
  /// • [uses] - A `List` defining how and where an asset may be used, in a
  /// the format of usecases and destinations, per the [terms] of the license.
  /// [Learn more](https://docs.mytiki.com/docs/specifying-terms-and-usage)
  /// about defining uses.
  ///
  /// • [terms] - The legal terms of the contract (a lot of words).
  ///
  /// • [origin] - An optional override of the default [origin] specified in
  /// [init]. Follow a reverse-DNS syntax. _i.e. com.myco.myapp_.
  ///
  /// • [tags] - A `List` of metadata tags included in the [TitleRecord]
  /// describing the asset, for your use in record search and filtering.
  /// [Learn more](https://docs.mytiki.com/docs/adding-tags)
  /// about adding tags. Only set IF a title does not already exist for the
  /// [ptr].
  ///
  /// • [titleDescription] - Sets the [TitleRecord] description IF a title
  /// does not already exist for the [ptr]. A short, human-readable,
  /// description of the [TitleRecord] as a future reminder.
  ///
  /// • [licenseDescription] - A short, human-readable,
  /// description of the [LicenseRecord] as a future reminder.
  ///
  /// • [expiry] - A [LicenseRecord] expiration date. Leave `null` if the
  /// license never expires.
  ///
  /// Returns the created [LicenseRecord]
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

  /// Create a new [TitleRecord].
  ///
  /// Parameters:
  ///
  /// • [ptr] - The Pointer Records identifies data stored in your system,
  /// similar to a foreign key.
  /// [Learn more](https://docs.mytiki.com/docs/selecting-a-pointer-record)
  /// about selecting good pointer records.
  ///
  /// • [origin] - An optional override of the default [origin] specified in
  /// [init]. Follow a reverse-DNS syntax. _i.e. com.myco.myapp_
  ///
  /// • [tags] - A `List` of metadata tags included in the [TitleRecord]
  /// describing the asset, for your use in record search and filtering.
  /// [Learn more](https://docs.mytiki.com/docs/adding-tags)
  /// about adding tags.
  ///
  /// • [description] - A short, human-readable, description of
  /// the [TitleRecord] as a future reminder.
  ///
  /// Returns the created [TitleRecord]
  Future<TitleRecord> title(String ptr,
      {String? origin,
      List<TitleTag> tags = const [],
      String? description}) async {
    TitleModel title = await _titleService.create(ptr,
        origin: origin, description: description, tags: tags);
    return TitleRecord(Bytes.base64UrlEncode(title.transactionId!), title.ptr,
        origin: title.origin, tags: title.tags, description: title.description);
  }

  /// Returns the latest [LicenseRecord] for a [ptr] or null if the
  /// title or license records are not found.
  ///
  /// Optionally, an [origin] may be specified. If null [origin] defaults
  /// to the [init] origin.
  ///
  /// The [LicenseRecord] returned may be expired or not applicable to a
  /// specific [LicenseUse]. To check license validity, use the [guard]
  /// method.
  LicenseRecord? latest(String ptr, {String? origin}) {
    TitleModel? title = _titleService.getByPtr(ptr, origin: origin);
    if (title == null) return null;
    LicenseModel? license = _licenseService.getLatest(title.transactionId!);
    if (license == null) return null;
    return _toLicense(title, license);
  }

  /// Returns all [LicenseRecord]s for a [ptr].
  ///
  /// Optionally, an [origin] may be specified. If null [origin] defaults
  /// to the [init] origin.
  ///
  /// The [LicenseRecord]s returned may be expired or not applicable to a
  /// specific [LicenseUse]. To check license validity, use the [guard]
  /// method.
  List<LicenseRecord> all(String ptr, {String? origin}) {
    TitleModel? title = _titleService.getByPtr(ptr, origin: origin);
    if (title == null) return [];
    List<LicenseModel> licenses = _licenseService.getAll(title.transactionId!);
    return licenses.map((license) => _toLicense(title, license)).toList();
  }

  /// Returns the [LicenseRecord] for an [id] or null if the license
  /// or corresponding title record is not found.
  LicenseRecord? getLicense(String id) {
    LicenseModel? license = _licenseService.getById(Bytes.base64UrlDecode(id));
    if (license == null) return null;
    TitleModel? title = _titleService.getById(license.title);
    if (title == null) return null;
    return _toLicense(title, license);
  }

  /// Returns the [TitleRecord] for an [id] or null if the record is
  /// not found.
  TitleRecord? getTitle(String id) {
    TitleModel? model = _titleService.getById(Bytes.base64UrlDecode(id));
    if (model == null) return null;
    return TitleRecord(id, model.ptr,
        origin: model.origin, tags: model.tags, description: model.description);
  }

  /// Guard against an invalid [LicenseRecord] for a List of [usecases] and
  /// [destinations].
  ///
  /// Use this method to verify a non-expired, [LicenseRecord] for the [ptr]
  /// exists, and permits the listed [usecases] and [destinations].
  ///
  /// Parameters:
  ///
  /// • [ptr] - The Pointer Record for the asset. Used to located the latest
  /// relevant [LicenseRecord].
  ///
  /// • [origin] - An optional override of the default [origin] specified in
  /// [init].
  ///
  /// • [usecases] - A List of usecases defining how the asset will be used.
  ///
  /// • [destinations] - A List of destinations defining where the asset will
  /// be used. _Often URLs_
  ///
  /// • [onPass] - A Function to execute automatically upon successfully
  /// resolving the [LicenseRecord] against the [usecases] and [destinations]
  ///
  /// • [onFail] - A Fucntion to execute automatically upon failure to resolve
  /// the [LicenseRecord]. Accepts a String parameter, holding an error
  /// message describing the reason for failure.
  ///
  /// This method can be used in two forms, 1) as a traditional guard,
  /// returning a pass/fail boolean. Or 2) as a wrapper around function.
  ///
  /// For example: An http that you want to run IF permitted by a
  /// [LicenseRecord].
  ///
  /// Option 1:
  /// ```
  /// bool pass = guard('ptr', [LicenseUsecase.attribution()]);
  /// if(pass) http.post(...);
  /// ```
  ///
  /// Option 2:
  /// ```
  /// guard('ptr', [LicenseUsecase.attribution()], onPass: () => http.post(...));
  /// ```
  ///
  /// Returns the created [TitleRecord]
  bool guard(String ptr, List<LicenseUsecase> usecases,
      {String? origin,
      List<String>? destinations,
      Function()? onPass,
      Function(String)? onFail}) {
    LicenseRecord? license = latest(ptr, origin: origin);
    if (license == null) {
      if (onFail != null) onFail('Missing license for ptr: $ptr');
      return false;
    }
    String? guardMessage = Guard.check(
        license, [LicenseUse(usecases, destinations: destinations)]);
    if (guardMessage == null) {
      if (onPass != null) onPass();
      return true;
    } else {
      if (onFail != null) onFail(guardMessage);
      return false;
    }
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

  Future<void> _syncRegistry() => _registryService.get(id).then((rsp) {
        if (rsp.addresses != null) {
          for (String address in rsp.addresses!) {
            _nodeService.addRef(address, (transactionId, contents, assetRef) {
              List<Uint8List> decoded = CompactSize.decode(contents);
              try {
                ContentSchema schema = ContentSchema.fromValue(
                    Bytes.decodeBigInt(decoded[0]).toInt());
                if (schema == ContentSchema.title) {
                  TitleModel title = TitleModel.decode(decoded.sublist(1));
                  title.transactionId = transactionId;
                  _titleService.add(title);
                } else if (schema == ContentSchema.license) {
                  //todo update cache for cross address titles
                  LicenseModel license =
                      LicenseModel.decode(null, decoded.sublist(1));
                  license.transactionId = transactionId;
                  _licenseService.add(license);
                }
              } catch (e) {
                // do nothing
              }
            });
          }
        }
      });
}
