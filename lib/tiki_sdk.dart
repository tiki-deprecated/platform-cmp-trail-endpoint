/// The SDK to handle data ownership and consent NFTs with TIKI.
///
/// ## API Reference
/// ### TikiSdkDataTypeEnum
/// The type of data to which the ownership refers.
/// * data_point
///   A specific and single ocurrence of a data.
/// * data_pool
///   A pool of data from different ocurrences.
/// * data_stream
///   A continuous stream of data.
/// ### TikiSdkDestination
/// The destination to which the data is consented to be used.
/// It is composed by `uses` and `paths`.
/// To allow all the constant is `TikiSdkDestination.all()`. To block all use `TikiSdkDestination.none()`.
/// #### uses
///  An optional list of application specific uses cases applicable to the given destination.<br />
///
///  Prefix with NOT to invert. _i.e. NOT ads_. </br >
///
/// #### paths
/// A list of paths, preferably URL without the scheme or reverse FQDN. Keep list short and use wildcard (*) matching. Prefix with NOT to invert. _i.e. NOT mytiki.com/*
/// #### WildCards
///
///  Wildcards are allowed in paths and uses using `*`.  To allow all uses, use a single item list with `*`.  To block all uses, create an empty list.
/// ### Assign Ownership
/// ```
/// String ownershipId = sdk.assignOwnership(source, type, contains, origin: origin);
/// ```
/// Assign ownership to a given `source` : data point, pool, or stream.<br />
/// The `types` describe the various types of data represented by the referenced data. <br />
/// Optionally, the `origin` can be overridden for the specific ownership grant.
///
/// ### Consent
/// ### Give Consent
/// ```
/// ConsentModel consent = sdk.modifyConsent(
///   ownershipId, destination, about: about, reward: reward, expiry: expiry);
/// ```
/// The consent is always given by overriding the previous consent. It is up to the implementer to verify the prior consent and modify it if necessary.
/// ### Get Consent
/// ```
/// ConsentModel consent = sdk. getConsent(source, origin: origin);
/// ```
/// Get the latest consent given for the source. The origin is optional and defaults to the one used in SDK builder.
/// ### Revoke Consent
/// ```
/// ConsentModel consent = sdk.modifyConsent(ownershipId, TikiSdkDestination.none());
/// ```
/// To revoke a given consent, use the constant TikiSdkDestition.none().
/// ### Apply Consent
/// ```
/// Function request = () => print('ok');
/// Function onBlocked = () => print('blocked');
/// sdk.applyConsent(source, destination, request, onBlocked: onBlocked);
/// ```
/// Runs a request if the consent was given for a specific source and destination. If the consent was not given, onBlocked is executed.
///
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
export 'utils/bytes.dart';

/// The TIKI SDK that enables the creation of Ownership and Consent NFTs for data.
///
/// Use [TikiSdkBuilder] to build an instance of this.
class TikiSdk {
  final OwnershipService _ownershipService;
  final ConsentService _consentService;
  final NodeService _nodeService;

  TikiSdk(OwnershipService ownershipService, ConsentService consentService,
      NodeService nodeService)
      : _ownershipService = ownershipService,
        _consentService = consentService,
        _nodeService = nodeService;

  /// The blockchain address that is in use by this TikiSdk.
  String get address => _nodeService.address;

  /// Assign ownership to a given [source].
  ///
  /// The [type] identifies which [TikiSdkDataTypeEnum] the ownership refers to.
  /// The list of items the data contains is described by [contains]. Optionally,
  /// a description about this ownership can be giben in [about] and the [origin]
  /// can be overridden for the specific ownership grant.
  /// It returns a base64 url-safe representation of the [OwnershipModel.transactionId].
  Future<String> assignOwnership(
      String source, TikiSdkDataTypeEnum type, List<String> contains,
      {String? about, String? origin}) async {
    OwnershipModel ownershipModel = await _ownershipService.create(
        source: source,
        type: type,
        origin: origin,
        about: about,
        contains: contains);
    return Bytes.base64UrlEncode(ownershipModel.transactionId!);
  }

  /// Gets latest consent given for a [source] and [origin].
  ///
  /// It does not validate if the consent is expired or if it can be applied to
  /// a specifi destination. For that, [applyConsent] should be used instead.
  ConsentModel? getConsent(String source, {String? origin}) {
    OwnershipModel? ownershipModel = getOwnership(source, origin: origin);
    if (ownershipModel == null) return null;
    return _consentService.getByOwnershipId(ownershipModel.transactionId!);
  }

  /// Gets the ownership for a [source] and optional [origin].
  OwnershipModel? getOwnership(String source, {String? origin}) =>
      _ownershipService.getBySource(source, origin: origin);

  /// Modify consent for an ownership identified by [ownershipId].
  ///
  /// The Ownership must be granted before modifying consent. Consent is applied
  /// on an explicit only basis. Meaning all requests will be denied by default
  /// unless the destination is explicitly defined in [destination].
  /// A blank list of [TikiSdkDestination.uses] or [TikiSdkDestination.paths]
  /// means revoked consent.
  Future<ConsentModel> modifyConsent(
      String ownershipId, TikiSdkDestination destination,
      {String? about, String? reward, DateTime? expiry}) async {
    ConsentModel consentModel = await _consentService.modify(
        Bytes.base64UrlDecode(ownershipId),
        destination: destination,
        about: about,
        reward: reward,
        expiry: expiry);
    return consentModel;
  }

  /// Apply consent for a given [source] and [destination].
  ///
  /// If consent exists for the destination and is not expired, [request] will be
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
