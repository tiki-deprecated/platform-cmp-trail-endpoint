library tiki_sdk;

/// TIKI Dart SDK API
abstract class TikiSdk {

  /// Get the SDK instance.
  TikiSdk get instance;

  /// Initialize the SDK
  ///
  /// Initializes the SDK loading the chain from local database and sync with
  /// remote back up, based on user and source identification.
  Future<TikiSdk> init({String source, List<String> tikiIds});

  /// Set Source
  ///
  /// Sets the source [id] that will be used as default origin for all data
  /// streams. Ideally it should follow a reversed FQDN syntax.
  /// _i.e. com.mycompany.myproduct_
  void setSource(String id);

  /// Identify user
  ///
  /// Provide a list of [tikiIds] to identify the user.
  /// The SDK will search for those TIKI IDs in the local database. The first
  /// that it finds it loads the chain and sync with backup.
  /// If none is found, it creates a new TIKI ID for the user.
  /// Return the TIKI ID that is been used in the current instance.
  Future<String> identifyUser(List<String> tikiIds);

  /// Assign Ownership
  ///
  /// The source will identify the data stream it wants to use, providing the
  /// [useCase] from [UseCaseEnum], that can be extended by the implementation.
  /// It can add no personally identifiable [metadata] to the identification.
  /// When identifying the data stream, a more specific [source] id than the
  /// one provided in the initialization.
  /// The ownership of the product should be applied in cascade to all
  /// more specific ids, i.e. com.company source ownership, gives com.company.product
  /// ownership too.
  /// Consent from another source, should be described in [consentOrigin].
  /// If the user has revoked consent to use this data stream, the SDK will
  /// throw an error.
  /// The source can add cross-origin references to other chains, by passing a list
  /// URIs in [crossChainRefs]
  Future<String?> assignOwnership(UseCaseEnum useCase, {
    Map<String, String> metadata,
    String source,
    String consentOrigin,
    List<Uri> crossChainRefs
  });

  /// Check ownership
  ///
  /// The source provides the [useCase] for that data stream to check use
  /// ownership.
  /// The SDK checks the ownership for the current identified user in the local
  /// chain.
  /// Other [userAddress] and [source] can be used. In that case, the SDK will check
  /// ownership in the backup.
  /// Return a boolean for the ownership and null if no registry is found.
  Future<String?> checkOwnership(UseCaseEnum useCase, {
    String source,
    String userAddress
  });

  /// Give consent By Id
  ///
  /// The source uses the [ownershipHash] to ask for consent from SDK.
  /// The SDK creates a registry of the consent and returns a unique id that
  /// identifies the consent registry.
  /// If the source has consent out of the chain, it must provide the [existingConsent]
  /// description for the user.
  /// If the [ownershipHash] cannot be found in the chain, it returns an error.
  Future<String> giveConsentById(String ownershipHash, {
    String existingConsent
  });

  /// Give consent By Use Case
  ///
  /// The source identifies the data stream it wants to use, by providing the
  /// [useCase].
  /// If the source has consent out of the chain, it must provide the [existingConsent]
  /// description for the user.
  ///
  Future<String> giveConsentByUseCase(UseCaseEnum useCase, {
    String source, String existingConsent
  });

  /// Revoke consent By Id
  ///
  /// The source uses the [ownershipHash] to revoke consent.
  /// The SDK creates a revoke consent registry returns a unique id that
  /// identifies the consent registry.
  /// If the [ownershipHash] cannot be found in the chain, it returns an error.
  Future<String> revokeConsentById(String ownershipHash);

  /// Revoke consent By Use Case
  ///
  /// The source identifies the data stream it wants to revoke the consent use,
  /// by providing the [useCase].
  /// The SDK creates a revoke consent registry and returns a unique id that
  /// identifies the consent registry.
  ///
  Future<String> revokeConsentByUseCase(UseCaseEnum useCase, {String source});

  /// Check consent By Id
  ///
  /// Check for the latest consent registry for this [ownershipHash].
  /// If none is found, check the latest registry for the useCase.
  /// Return a boolean for the consent and null if no registry is found.
  /// If the [ownershipHash] cannot be found in the chain, it returns an error.
  Future<String> checkConsentById(String ownershipHash);

  /// Check consent By UseCase
  ///
  /// Check for the latest consent for the useCase.
  /// Return a boolean for the consent and null if no registry is found.
  Future<String> checkConsentByUseCase(UseCaseEnum useCase, {String source});

}

enum UseCaseEnum{
  all
}