/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */
/// {@category SDK}
import '../tiki_sdk_destination.dart';
import 'consent_repository.dart';

/// The service to manage consent registries.
class ConsentService {
  final ConsentRepository consentRepository;

  /// The default origin for all consents.
  final String _defaultOrigin;

  ConsentService(db) : consentRepository = ConsentRepository(_defaultOrigin, db);

  /// Modify consent for [source].
  ///
  /// Ownership must be granted before modifying consent. 
  Future<String> create(
      String source, {
        String? origin, List<TikiSdkDestination> destinations) {
    throw UnimplementedError();
    // 1 - get the Ownership for that source.
    // 2 - get latest ConsentModel from database by Ownership trasaction id
    // 3 - check if destinations change the current consent (check actual destination
    // NOT keywords and wildcards) 
    // 4 - create a ConsentModel with the destination summary
    // 5 - create transaction in node service.
    // content - [content schema byte length][content schema ID][payload].
    // content schema ID - 2 for Consent.
    // payload - serialize ConsentModel without transaction ID.
    // 6 - save ConsentModel to the database with transaction ID.
  }

  // todo get latest consent
  get();

  /// Apply consent for [source] given a specific [destination].
  /// 
  /// If consent exists for the destination, [request] will be
  /// executed. Else [onBlocked] is called.
  /// Consent is applied on an explicit only basis. Meaning all requests 
  /// will be denied by default unless the destination is explicitly defined in 
  /// [destination].
  Future<void> apply(
    String source, 
    TikiSdkDestination destination, 
    Function request,
    {String? origin, void Function(String)? onBlocked}
  ){
    // 1 - get the latest ConsentModel from database by source and origin
    // 2 - check if destiantion is allowed for source
    // 3 - execute request or onBlocked
    throw UnimplementedError();
  }

}