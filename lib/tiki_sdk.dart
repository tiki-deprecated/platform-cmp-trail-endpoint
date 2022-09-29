/// The SDK to handle data ownership and consent NFTs with TIKI.
/// {@category SDK}
// ignore_for_file: unused_field

library tiki_sdk_dart;

export 'tiki_sdk_data_type_enum.dart';
export 'tiki_sdk_destination.dart';

import 'dart:convert';

import 'package:sqlite3/sqlite3.dart';

import 'consent/consent_service.dart';
import 'consent/consent_model.dart';
import 'node/l0_storage.dart';
import 'node/node_service.dart';
import 'ownership/ownership_model.dart';
import 'ownership/ownership_service.dart';
import 'tiki_sdk_data_type_enum.dart';
import 'tiki_sdk_destination.dart';

class TikiSdk {
  late final OwnershipService _ownershipService;
  late final ConsentService _consentService;
  late final NodeService _nodeService;

  /// The origin that will be used as default origin for all ownership
  /// assignments. It should follow a reversed FQDN syntax.
  /// _i.e. com.mycompany.myproduct_
  final String origin;

  /// The API Key for the TIKI public backup. If null, blocks will not
  /// be backed up. Register your application at mytiki.com to get your
  /// application’s API key.
  final String? _apiKey;

  /// List of ids (wallet addresses) for the current user. The first
  /// id in the list with a known private key will become the primary
  /// chain, with all others operating in a read-only capacity.
  List<String> _ids = [];

  TikiSdk(this.origin, {String? apiKey}) : _apiKey = apiKey;

  Future<TikiSdk> init(
      Database database, KeyStorage keyStorage, L0Storage l0storage,
      {List<String>? ids}) async {
    if (ids != null) _ids = ids;
    _nodeService = await NodeService().init(database, keyStorage, l0storage);
    _ownershipService = OwnershipService(origin, _nodeService, database);
    _consentService = ConsentService(database, _nodeService);
    return this;
  }

  List<String> get ids => _ids;

  void addId(String id) => _ids.add(id);

  void removeId(String id) => _ids.remove(id);

  /// Assign ownership to a given [source] : data point, pool, or stream.
  /// [types] describe the various types of data represented by
  /// the referenced data. Optionally, the [origin] can be overridden
  /// for the specific ownership grant.
  Future<String> grantOwnership(String source, List<TikiSdkDataTypeEnum> types,
          {String? origin}) async =>
      base64Url.encode(await _ownershipService.create(
          source: source, types: types, origin: origin ?? this.origin));

  /// Modify consent for [data]. Ownership must be granted before
  /// modifying consent. Consent is applied on an explicit only basis.
  /// Meaning all requests will be denied by default unless the
  /// destination is explicitly defined in [destinations].
  /// A blank list of [TikiSdkDestination.uses] or [TikiSdkDestination.paths]
  /// means revoked consent.
  Future<String> modifyConsent(
          String ownershipId, TikiSdkDestination destination,
          {String? about, String? reward}) async =>
      base64Url.encode(await _consentService.create(
          base64Url.decode(ownershipId),
          about: about,
          reward: reward,
          destinations: destination));

  /// Gets latest consent
  List<OwnershipModel> getOwnerships() => _ownershipService.getAll();

  /// Gets latest consent
  ConsentModel? getConsent(String source, {String? origin}) {
    OwnershipModel? ownershipModel =
        _ownershipService.getBySource(source, origin: origin);
    if (ownershipModel == null) return null;
    return _consentService.getByOwnershipId(ownershipModel.transactionId!);
  }

  /// Apply consent for [data] given a specific [destination].
  /// If consent exists for the destination, [request] will be
  /// executed. Else [onBlocked] is called.
  Future<void> applyConsent(
      String source, TikiSdkDestination destination, Function request,
      {void Function(String)? onBlocked, String? origin}) async {
    try {
      OwnershipModel? ownership =
          _ownershipService.getBySource(source, origin: origin ?? this.origin);
      if (ownership == null && onBlocked != null) onBlocked(source);
      ConsentModel? consentModel =
          _consentService.getByOwnershipId(ownership!.transactionId!);
      if (_checkConsent(consentModel, destination)) {
        request();
      } else {
        if (onBlocked != null) onBlocked(source);
      }
    } catch (e) {
      if (onBlocked != null) onBlocked(source);
    }
  }

  bool _checkConsent(
      ConsentModel? consentModel, TikiSdkDestination destination) {
    throw UnimplementedError('TDB in next version');
  }
}
