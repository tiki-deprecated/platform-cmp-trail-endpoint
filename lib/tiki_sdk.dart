/// The SDK to handle data ownership and consent NFTs with TIKI.
/// {@category SDK}
// ignore_for_file: unused_field

library tiki_sdk_dart;

export 'tiki_sdk_data_type_enum.dart';
export 'tiki_sdk_destination.dart';

import 'dart:convert';

import 'package:sqlite3/sqlite3.dart';

import 'consent/consent_service.dart';
import 'node/l0_storage.dart';
import 'node/node_service.dart';
import 'ownership/ownership_service.dart';
import 'tiki_sdk_data_type_enum.dart';
import 'tiki_sdk_destination.dart';

class TikiSdk {
  late final String _defaultOrigin;
  late final OwnershipService _ownershipService;
  late final ConsentService _consentService;
  late final NodeService _nodeService;

  /// The origin that will be used as default origin for all ownership
  /// assignments. It should follow a reversed FQDN syntax.
  /// _i.e. com.mycompany.myproduct_
  /// List of ids (wallet addresses) for the current user. The first
  /// id in the list with a known private key will become the primary
  /// chain, with all others operating in a read-only capacity.
  ///  /// The API Key for the TIKI public backup. If null, blocks will not
  /// be backed up. Register your application at mytiki.com to get your
  /// application’s API key.
  Future<TikiSdk> init(String origin, Database database, KeyStorage keyStorage,
      L0Storage l0storage,
      {String? id}) async {
    _nodeService = await NodeService().init(
      database,
      keyStorage,
      l0storage,
      primary: id,
    );
    _ownershipService = OwnershipService(origin, _nodeService, database);
    _consentService = ConsentService(database, _nodeService);
    return this;
  }

  String get id => _nodeService.address;

  /// Assign ownership to a given [source] : data point, pool, or stream.
  /// [types] describe the various types of data represented by
  /// the referenced data. Optionally, the [origin] can be overridden
  /// for the specific ownership grant.
  Future<String> assignOwnership(
      String source, TikiSdkDataTypeEnum type, List<String> contains,
      {String? origin}) async {
    OwnershipModel ownershipModel = await _ownershipService.create(
        source: source, type: type, origin: origin);
    return base64Url.encode(ownershipModel.transactionId!);
  }

  /// Gets latest consent
  ConsentModel? getConsent(String source, {String? origin}) {
    OwnershipModel? ownershipModel =
        _ownershipService.getBySource(source, origin: origin);
    if (ownershipModel == null) return null;
    return _consentService.getByOwnershipId(ownershipModel.transactionId!);
  }

  /// Modify consent for [data]. Ownership must be granted before
  /// modifying consent. Consent is applied on an explicit only basis.
  /// Meaning all requests will be denied by default unless the
  /// destination is explicitly defined in [destinations].
  /// A blank list of [TikiSdkDestination.uses] or [TikiSdkDestination.paths]
  /// means revoked consent.
  Future<ConsentModel> modifyConsent(
      String ownershipId, TikiSdkDestination destination,
      {String? about, String? reward}) async {
    ConsentModel consentModel = await _consentService.create(
        base64Url.decode(ownershipId),
        about: about,
        reward: reward,
        destinations: destination);
    return consentModel;
  }

  /// Apply consent for [data] given a specific [destination].
  /// If consent exists for the destination, [request] will be
  /// executed. Else [onBlocked] is called.
  Future<void> applyConsent(
      String source, TikiSdkDestination destination, Function request,
      {void Function(String)? onBlocked, String? origin}) async {
    try {
      OwnershipModel? ownership =
          _ownershipService.getBySource(source, origin: origin);
      if (ownership == null) {
        if (onBlocked != null) onBlocked('No ownership');
        return;
      }
      ConsentModel? consentModel =
          _consentService.getByOwnershipId(ownership.transactionId!);
      if (consentModel == null) {
        if (onBlocked != null) onBlocked('No consent');
        return;
      }
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
      ConsentModel consentModel, TikiSdkDestination destination) {
    bool pathConsent = false;
    bool useConsent = false;
    List<String> destinationPaths = destination.paths;
    List<String> consentPaths = consentModel.destination.paths;
    pathConsent = _compareConsentLists(consentPaths, destinationPaths);
    List<String> destinationUses = destination.uses;
    List<String> consentUses = consentModel.destination.uses;
    useConsent = _compareConsentLists(consentUses, destinationUses);
    return pathConsent && useConsent;
  }

  bool _compareConsentLists(List<String> consent, List<String> destination) {
    for (int i = 0; i < destination.length; i++) {
      String path = destination[i];
      if (consent.contains(path)) return true;
      List<String> paths = path.split('/');
      if (paths.length > 1) {
        for (int j = 0; j < paths.length; j++) {
          if (consent.contains('${paths[j]}/*')) {
            for (int k = j + 1; k < paths.length; k++) {
              if (consent.contains('NOT ${paths[k]}')) {
                return false;
              }
            }
            return true;
          }
        }
      }
    }
    return false;
  }
}
