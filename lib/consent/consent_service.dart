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

  ConsentService(db) : consentRepository = ConsentRepository(db);

  /// Modify consent for [source].
  ///
  /// Ownership must be granted before modifying consent. 

  Future<String> modifyConsent(
      String source, List<TikiSdkDestination> destinations) {
    throw UnimplementedError();
  }

  /// Check if consent for [source] given a specific [destination].
  /// 
  /// Consent is applied on
  /// an explicit only basis. Meaning all requests will be denied by default unless
  /// the destination is explicitly defined in [destinations].
  bool isGranted(
    String source,
    TikiSdkDestination destination,
  ) {
    throw UnimplementedError();
  }
}