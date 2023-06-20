/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

/// The TIKI trail project is an immutable, distributed, record system for data
/// transactions. Use [TikiTrail] as the primary entrypoint.
library tiki_trail;

import 'dart:typed_data';

import 'package:sqlite3/common.dart';
import 'package:tiki_idp/tiki_idp.dart';

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
import 'key.dart';
import 'l0/storage/storage_service.dart';
import 'license.dart';
import 'license_record.dart';
import 'node/backup/backup_service.dart';
import 'node/block/block_service.dart';
import 'node/node_service.dart';
import 'node/transaction/transaction_service.dart';
import 'node/xchain/xchain_service.dart';
import 'payable.dart';
import 'payable_record.dart';
import 'receipt.dart';
import 'receipt_record.dart';
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
export 'payable.dart';
export 'payable_record.dart';
export 'receipt.dart';
export 'receipt_record.dart';
export 'title.dart';
export 'title_record.dart';

/// The primary entrypoint for the library —use to create, get, and enforce records.
class TikiTrail {
  final NodeService _nodeService;

  /// Interact with [TitleRecord]s.
  late final Title title;

  /// Interact with [LicenseRecord]s.
  late final License license;

  /// Interact with [PayableRecord]s.
  late final Payable payable;

  /// Interact with [ReceiptRecord]s.
  late final Receipt receipt;

  /// Prefer [withId] and [init] instead.
  /// @nodoc
  TikiTrail(String origin, this._nodeService, TikiIdp idp) {
    TitleService titleService =
        TitleService(origin, _nodeService.database, _nodeService);
    LicenseService licenseService =
        LicenseService(_nodeService.database, _nodeService);
    PayableService payableService =
        PayableService(_nodeService.database, _nodeService);
    ReceiptService receiptService =
        ReceiptService(_nodeService.database, _nodeService);
    title = Title(titleService);
    license = License(licenseService, this);
    payable = Payable(payableService, this);
    receipt = Receipt(receiptService, this);
    _syncRegistry(_nodeService.id, titleService, licenseService, payableService,
        receiptService, idp);
  }

  /// Use before [init] to add a wallet address and keypair
  /// to the [keyStorage] for [id].
  ///
  /// If the private keys are missing a new address and
  /// private key is created and registered to the [id].
  ///
  /// Returns the valid (created or provided) address
  static Future<Key> withId(String id, TikiIdp idp) async {
    await idp.key(id);
    return Key.pem(id, await idp.export(id, public: true));
  }

  /// Returns a new initialized [TikiTrail] instance.
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
  /// • [database] - Platform-specific sqlite3 implementation. Always open
  /// beforehand.
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
  static Future<TikiTrail> init(String publishingId, String origin, TikiIdp idp,
      Key key, CommonDatabase database,
      {int maxTransactions = 1,
      Duration blockInterval = const Duration(minutes: 1),
      String? customerAuth}) async {
    StorageService storageService = StorageService(key.id, idp);

    Registry registry =
        await idp.register(key.id, key.address, token: customerAuth);

    NodeService nodeService = NodeService()
      ..blockInterval = blockInterval
      ..maxTransactions = maxTransactions
      ..transactionService =
          TransactionService(database, idp, appKeyId: registry.appKeyId)
      ..blockService = BlockService(database)
      ..xChainService = XChainService(storageService, idp, database)
      ..key = key;
    nodeService.backupService = await BackupService(
            storageService, idp, database, nodeService.getBlock, key)
        .init();
    await nodeService.init();

    return TikiTrail(origin, nodeService, idp);
  }

  /// Returns the in-use wallet [address].
  ///
  /// Refers to the wallet address currently in use by the instance. This
  /// [address] serves as a unique identifier for a particular combination of
  /// user and device. If either the user or the device changes,
  /// use a different [address].
  String get address => _nodeService.address;

  // Returns the in-use id [id].
  //
  // The customer provided identifier for the user in use by the instance.
  // This [id] serves as a unique identifier for a user. Set the
  // [id] using the [withId] method before calling [init].
  String get id => _nodeService.id;

  /// Guard against an invalid [LicenseRecord] for a List of [usecases] and
  /// [destinations].
  ///
  /// Use this method to verify a non-expired [LicenseRecord] for the [ptr]
  /// exists and permits the listed [usecases] and [destinations].
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
  /// • [onFail] - A Function to execute automatically upon failure to resolve
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

  /// Use the Registry Service to sync new blocks and transactions created on
  /// other devices for the [id].
  Future<void> _syncRegistry(
          String keyId,
          TitleService titleService,
          LicenseService licenseService,
          PayableService payableService,
          ReceiptService receiptService,
          TikiIdp idp) =>
      idp.registry(keyId, id).then((rsp) {
        rsp.addresses.forEach((address) => _nodeService.sync(address, (txn) {
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
