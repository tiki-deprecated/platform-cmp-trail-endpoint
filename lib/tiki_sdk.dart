/// The SDK to handle data ownership and consent NFTs with TIKI.
library tiki_sdk_dart;

import 'consent/consent_service.dart';
import 'node/node_service.dart';
import 'ownership/ownership_service.dart';
import 'tiki_sdk_data_type_enum.dart';
import 'tiki_sdk_destination.dart';
import 'utils/bytes.dart';

export 'tiki_sdk_builder.dart';
export 'tiki_sdk_data_type_enum.dart';
export 'tiki_sdk_destination.dart';

class TikiSdk {
  late final OwnershipService _ownershipService;
  late final ConsentService _consentService;
  late final NodeService _nodeService;

  TikiSdk();

  /// The blockchain address that is in use by this TikiSdk.
  String get address => _nodeService.address;

  set ownershipService(OwnershipService ownershipService) =>
      _ownershipService = ownershipService;
  set consentService(ConsentService consentService) =>
      _consentService = consentService;
  set nodeService(NodeService nodeService) => _nodeService = nodeService;

  /// Assign ownership to a given [source] : data point, pool, or stream.
  /// [types] describe the various types of data represented by
  /// the referenced data. Optionally, the [origin] can be overridden
  /// for the specific ownership grant.
  Future<String> assignOwnership(
      String source, TikiSdkDataTypeEnum type, List<String> contains,
      {String? origin}) async {
    OwnershipModel ownershipModel = await _ownershipService.create(
        source: source, type: type, origin: origin);
    return Bytes.base64UrlEncode(ownershipModel.transactionId!);
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
      {String? about, String? reward, DateTime? expiry}) async {
    ConsentModel consentModel = await _consentService.modify(
        Bytes.base64UrlDecode(ownershipId),
        about: about,
        reward: reward,
        expiry: expiry,
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
    if (consentModel.expiry != null &&
        consentModel.expiry!.isBefore(DateTime.now())) {
      return false;
    }
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
