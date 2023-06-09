/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */
library tiki_sdk_dart;

import 'dart:typed_data';

import 'package:sqlite3/common.dart';

import 'cache/content_schema.dart';
import 'cache/license/license_model.dart';
import 'cache/license/license_service.dart';
import 'cache/license/license_use.dart';
import 'cache/license/license_usecase.dart';
import 'cache/payable/payable_model.dart';
import 'cache/payable/payable_service.dart';
import 'cache/receipt/receipt_model.dart';
import 'cache/receipt/receipt_service.dart';
import 'cache/title/title_model.dart';
import 'cache/title/title_service.dart';
import 'l0/auth/auth_service.dart';
import 'l0/registry/registry_model_rsp.dart';
import 'l0/registry/registry_service.dart';
import 'l0/storage/storage_service.dart';
import 'license.dart';
import 'license_record.dart';
import 'node/backup/backup_service.dart';
import 'node/block/block_service.dart';
import 'node/key/key_model.dart';
import 'node/key/key_service.dart';
import 'node/key/key_storage.dart';
import 'node/node_service.dart';
import 'node/transaction/transaction_service.dart';
import 'node/xchain/xchain_service.dart';
import 'payable.dart';
import 'receipt.dart';
import 'title.dart';
import 'title_record.dart';
import 'utils/bytes.dart';
import 'utils/compact_size.dart';
import 'utils/guard.dart';

export 'cache/license/license_use.dart';
export 'cache/license/license_usecase.dart';
export 'cache/title/title_tag.dart';
export 'license.dart';
export 'license_record.dart';
export 'node/key/key_storage.dart';
export 'payable.dart';
export 'payable_record.dart';
export 'title.dart';
export 'title_record.dart';

/// The primary class for the tiki_sdk_dart library.
/// Use this to create, get, and enforce [LicenseRecord]s and
/// [TitleRecord]s.
class TikiSdk {
  final NodeService _nodeService;

  late final Title title;
  late final License license;
  late final Payable payable;
  late final Receipt receipt;

  /// Prefer [withAddress] and [init] instead.
  /// @nodoc
  TikiSdk(
      String origin, NodeService nodeService, RegistryService registryService)
      : _nodeService = nodeService {
    TitleService titleService =
        TitleService(origin, nodeService, nodeService.database);
    LicenseService licenseService =
        LicenseService(nodeService.database, nodeService);
    PayableService payableService =
        PayableService(nodeService.database, nodeService);
    ReceiptService receiptService =
        ReceiptService(nodeService.database, nodeService);
    title = Title(titleService);
    license = License(licenseService, this);
    payable = Payable(payableService, this);
    receipt = Receipt(receiptService, this);
    _syncRegistry(titleService, licenseService, payableService, receiptService,
        registryService);
  }

  /// Use before [init] to add a wallet address and keypair
  /// to the [keyStorage] for [id].
  ///
  /// If the private keys are missing a new address and
  /// private key is created and registered to the [id].
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
  ///
  /// • [maxTransactions] - The maximum number of transactions to bundle
  /// in a block. Use in combination with [blockInterval]. Default is 1.
  ///
  /// • [blockInterval] - The duration before a block is automatically
  /// created if there are any pending transactions AND the [maxTransactions]
  /// limit has not been reached. Use in combination with [blockInterval].
  /// Default is 1 minute.
  ///
  /// • [customerAuth] - A customer provided Authorization Token (JWT) for
  /// use in [id] registration. Use [customerAuth] to add user identity
  /// verification. Configure in [console](https://console.mytiki.com)
  static Future<TikiSdk> init(String publishingId, String origin,
      KeyStorage keyStorage, String id, CommonDatabase database,
      {int maxTransactions = 1,
      Duration blockInterval = const Duration(minutes: 1),
      String? customerAuth}) async {
    KeyService keyService = KeyService(keyStorage);
    KeyModel? primaryKey = await keyService.get(id);
    if (primaryKey == null) {
      throw StateError("Use keystore() to initialize address");
    }

    AuthService authService = AuthService(publishingId);
    StorageService storageService =
        StorageService(primaryKey.privateKey, authService);
    RegistryService registryService =
        RegistryService(primaryKey.privateKey, authService);
    RegistryModelRsp registryRsp = await registryService.register(
        id, Bytes.base64UrlEncode(primaryKey.address),
        customerAuth: customerAuth);

    NodeService nodeService = NodeService()
      ..blockInterval = blockInterval
      ..maxTransactions = maxTransactions
      ..transactionService =
          TransactionService(database, appKey: registryRsp.signKey)
      ..blockService = BlockService(database)
      ..xChainService = XChainService(storageService, database)
      ..primaryKey = primaryKey;
    nodeService.backupService = BackupService(
        storageService, database, primaryKey, nodeService.getBlock);
    await nodeService.init();

    return TikiSdk(origin, nodeService, registryService);
  }

  /// Returns the in-use wallet [address].
  ///
  /// Refers to the blockchain wallet address currently in use by this [TikiSdk]
  /// instance. This [address] serves as a unique identifier for a particular
  /// combination of user and device. If either the user or the device changes,
  /// use a a different [address].
  String get address => _nodeService.address;

  // Returns the in-use id [id]
  //
  // A customer provided identifier for the user, in use by this [TikiSdk]
  // instance. This [id] serves as a unique identifier for a user. Set the
  // [id] using the [withId] method before calling [init].
  String get id => _nodeService.id;

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
    TitleRecord? title = this.title.get(ptr, origin: origin);
    if (title == null) {
      if (onFail != null) onFail('Missing title for ptr: $ptr');
      return false;
    }
    LicenseRecord? license = this.license.latest(title);
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

  /// Method to sync missing blocks and transactions for the [id] using
  /// the L0 Registry Service.
  Future<void> _syncRegistry(
          TitleService titleService,
          LicenseService licenseService,
          PayableService payableService,
          ReceiptService receiptService,
          RegistryService registryService) =>
      registryService.get(id).then((rsp) {
        rsp.addresses?.forEach((address) => _nodeService.sync(address, (txn) {
              List<Uint8List> decodedContents =
                  CompactSize.decode(txn.contents);
              ContentSchema schema = ContentSchema.fromValue(
                  Bytes.decodeBigInt(decodedContents[0]).toInt());
              if (schema == ContentSchema.title) {
                TitleModel title =
                    TitleModel.decode(decodedContents.sublist(1));
                title.transactionId = txn.id;
                titleService.tryAdd(title);
              } else if (schema == ContentSchema.license) {
                if (txn.assetRef.startsWith("txn://")) {
                  Uint8List title =
                      Bytes.base64UrlDecode(txn.assetRef.split("://").last);
                  LicenseModel license =
                      LicenseModel.decode(title, decodedContents.sublist(1));
                  license.transactionId = txn.id;
                  licenseService.tryAdd(license);
                }
              } else if (schema == ContentSchema.payable) {
                if (txn.assetRef.startsWith("txn://")) {
                  Uint8List license =
                      Bytes.base64UrlDecode(txn.assetRef.split("://").last);
                  PayableModel payable =
                      PayableModel.decode(license, decodedContents.sublist(1));
                  payable.transactionId = txn.id;
                  payableService.tryAdd(payable);
                }
              } else if (schema == ContentSchema.receipt) {
                if (txn.assetRef.startsWith("txn://")) {
                  Uint8List payable =
                      Bytes.base64UrlDecode(txn.assetRef.split("://").last);
                  ReceiptModel receipt =
                      ReceiptModel.decode(payable, decodedContents.sublist(1));
                  receipt.transactionId = txn.id;
                  receiptService.tryAdd(receipt);
                }
              }
            }));
      });
}
