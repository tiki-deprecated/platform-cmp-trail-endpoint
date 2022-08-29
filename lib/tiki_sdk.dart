library tiki_sdk_dart;

import 'tiki_sdk_data_type_enum.dart';
import 'tiki_sdk_destination.dart';

// TODO investigate optional debug
class TikiSdk {
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

  Future<TikiSdk> init({List<String>? ids}) async {
    if (ids != null) _ids = ids;
    return this;
  }

  List<String> get ids => _ids;

  void addId(String id) => _ids.add(id);

  void removeId(String id) => _ids.remove(id);

  /// Assign ownership to a given [data] point, pool, or stream.
  /// [types] describe the various types of data represented by
  /// the referenced data. Optionally, the [origin] can be overridden
  /// for the specific ownership grant.
  Future<String> grantOwnership(String data, List<TikiSdkDataTypeEnum> types,
      {String? origin}) {
    throw UnimplementedError();
  }

  /// Modify consent for [data]. Ownership must be granted before
  /// modifying consent. Consent is applied on an explicit only basis.
  /// Meaning all requests will be denied by default unless the
  /// destination is explicitly defined in [destinations].
  Future<String> modifyConsent(
      String data, List<TikiSdkDestination> destinations) {
    throw UnimplementedError();
  }

  /// Apply consent for [data] given a specific [destination].
  /// If consent exists for the destination, [request] will be
  /// executed. Else [onBlocked] is called.
  Future<void> applyConsent(
      String data, TikiSdkDestination destination, Function request,
      {void Function(String)? onBlocked}) {
    throw UnimplementedError();
  }
}
