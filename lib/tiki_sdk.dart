/// The SDK to handle data ownership and consent NFTs with TIKI.
///
/// ## Initialization
///
/// To initialize the TIKI SDK, use the [TikiSdkBuilder].
///
/// ```
/// TikiSdkBuilder sdkBuilder = TikiSdkBuilder()
///      ..databaseDir(<databaseDir>)
///      ..keyStorage(FlutterKeyStorage())
///      ..address(_address)
///      ..publishingId(_publishingId)
///      ..origin(_origin!);
/// TikiSdk tikiSdk = sdkBuilder.build();
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
library tiki_sdk_dart;

import 'cache/consent/consent_service.dart';
import 'cache/ownership/ownership_service.dart';
import 'node/node_service.dart';
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

  /// Builds the TikiSdk. Should not be used directly. Use [TikiSdkBuilder] instead.
  TikiSdk(OwnershipService ownershipService, ConsentService consentService,
      NodeService nodeService)
      : _ownershipService = ownershipService,
        _consentService = consentService,
        _nodeService = nodeService;

  /// The blockchain address that is in use by this TikiSdk.
  ///
  /// This property refers to the blockchain address that is currently in use
  /// by this TikiSdk instance. This address serves as a unique identifier for
  /// a particular combination of user and device. If either the user or the
  /// device changes, a different blockchain address should be used.
  ///
  /// Once the TikiSdk is initialized, it is important to store this blockchain
  /// address somewhere else so that it can be retrieved and used the next time
  /// the user initializes the sdk on the same device.
  String get address => _nodeService.address;

  /// Creates an Ownership NFT that identify the owner of a data [source].
  ///
  /// This method creates an Ownership NFT (Non-Fungible Token)
  /// to verify ownership of a specific piece of data in the [TikiSdk]. The
  /// Ownership NFT created, establishes a connection between the owner and the
  /// piece of data from a [source].
  ///
  /// Parameters:
  /// [source] a String that represents which is the data source to be owned.
  /// [type] the [TikiSdkDataTypeEnum] that identifies the type of data.
  /// [contains] a list of items that the data source contains.
  /// [about] an optional description of the ownership, defaults to `null`.
  /// [origin] an override for the default origin, defaiults to `null`.
  ///
  /// Once the Ownership NFT has been created, this method returns the transactionId
  /// of the Ownership NFT
  ///
  /// It returns a Future<String> that represents the base64 url-safe encoded string
  /// of the transactionId of the Ownership NFT stored in the blockchain. This
  /// identifier is crucial to request consent from the user to use the data source
  /// associated with this ownership.
  Future<String> assignOwnership(
      String source, TikiSdkDataTypeEnum type, List<String> contains,
      {String? about, String? origin}) async {
    OwnershipModel ownershipModel = await _ownershipService.create(
      source: source,
      type: type,
      contains: contains,
      about: about,
      origin: origin,
    );
    return Bytes.base64UrlEncode(ownershipModel.transactionId!);
  }

  /// Gets the Ownership NFT associated with the given data [source].
  ///
  /// Searches the ownership cache for the specific data [source] and returns
  /// the [OwnershipModel] object. An optional [origin] parameter can be passed in
  /// to search for a specific ownership grant for the given source.
  ///
  /// Returns a [OwnershipModel] object that represents the Ownership NFT for the
  /// given data [source]. If no ownership is found for the given [source], it
  /// returns null.
  OwnershipModel? getOwnership(String source, {String? origin}) =>
      _ownershipService.getBySource(source, origin: origin);

  /// Modify consent for the usage of the data identified by [ownershipId].
  ///
  /// In order to modify consent for an Ownership, it must have been assigned
  /// beforehand. Consent is applied explicitly only, meaning that all requests
  /// will be denied by default unless the destination is explicitly defined in
  /// the [destination] parameter. An empty list of [TikiSdkDestination.uses] or
  /// [TikiSdkDestination.paths] means that consent has been revoked.
  ///
  /// Additional parameters are optional, such as the [about] parameter which
  /// allows for a description of the consent modification, and the [reward]
  /// parameter which specifies any compensation being offered for consent.
  /// The [expiry] parameter sets an optional expiration date for the consent.
  ///
  /// The method returns the modified ConsentModel.
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

  /// Gets the latest consent given for a data [source] and [origin].
  ///
  /// The method retrieves the [OwnershipModel] associated with the data source
  /// and origin, and uses its transaction ID to retrieve the latest [ConsentModel]
  /// registered on the blockchain.
  ///
  /// The consent model returned may be expired or not applicable to a specific
  /// destination. To ensure the consent is valid for a specific usage, use the
  /// [applyConsent] method instead.
  ///
  /// Returns the latest [ConsentModel] or null if no consent has been given for
  /// the specified source and origin.
  ConsentModel? getConsent(String source, {String? origin}) {
    OwnershipModel? ownershipModel = getOwnership(source, origin: origin);
    if (ownershipModel == null) return null;
    return _consentService.getByOwnershipId(ownershipModel.transactionId!);
  }

  /// Apply consent for a given [source] and [destination].
  ///
  /// This method is used to verify the user consent for a specified data [source]
  /// and [destination], by executing a [request] if valid consent exists.
  /// If no valid consent exists, the function calls the [onBlocked] callback function,
  /// passing a message that provides information on why the request was blocked.
  ///
  /// The [onBlocked] function receives the reason of the request been blocked or
  /// the transaction Id for the Consent NFT that blocked it. Additionally, an
  /// optional origin parameter can be passed to specify the data source's origin.
  ///
  /// The [onBlocked] function is called there is an issue with fetching the
  /// ownership or consent model.
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
    useConsent = _compareUseLists(consentUses, destinationUses);
    return pathConsent && useConsent;
  }

  bool _compareConsentLists(List<String> consent, List<String> destination) {
    for (int i = 0; i < destination.length; i++) {
      String path = destination[i];
      if (consent.contains(path)) return true;
      if (consent.contains("*")) return true;
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

  bool _compareUseLists(List<String> use, List<String> destination) {
    for (int i = 0; i < destination.length; i++) {
      String path = destination[i];
      if (use.contains(path)) return true;
      if (use.contains("*")) return true;
      List<String> paths = path.split('/');
      if (paths.length > 1) {
        for (int j = 0; j < paths.length; j++) {
          if (use.contains('${paths[j]}/*')) {
            for (int k = j + 1; k < paths.length; k++) {
              if (use.contains('NOT ${paths[k]}')) {
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
