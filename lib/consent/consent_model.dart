/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */
/// {@category SDK}
import '../tiki_sdk_destination.dart';

/// The registry of consent to use a data asset identified by [assetRef].
class ConsentModel {
  /// The asset reference of the transaction that identifies the ownership of it.
  String assetRef;

  /// The [TikiSdkDestination] that identifies the usage of this data.
  TikiSdkDestination destination;

  /// The optional description of the consent.
  String? about;

  /// The optional reward that the user will receive for giving consent.
  String? reward;

  /// Builds a new [ConsentModel]
  ConsentModel(this.assetRef, this.destination, {this.about, this.reward});
}
