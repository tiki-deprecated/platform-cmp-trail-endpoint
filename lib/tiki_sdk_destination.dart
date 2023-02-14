/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */
import 'dart:convert';
import 'dart:typed_data';

import 'utils/compact_size.dart';

/// The destination where data can be used with its corresponding usage consent.
///
/// The class has two properties, [paths] and [uses], which define the paths
/// where the data can be used and the use cases of the data.
/// These properties are for internal use of the implementer and can be defined
/// with any appropriate string.
///
/// For more information about data usage for the end user, the [about] property
/// in [ConsentModel] and [OwnershipModel] should be used.
///
/// To revoke all destinations, use [TikiSdkDestination.none].
/// To allow any destination, use [TikiSdkDestionation.all].
class TikiSdkDestination {
  /// List of optional application-specific use cases applicable to the given
  /// destination.
  ///
  /// Use the prefix "NOT" to invert a use case. For example, "NOT ads" means
  /// that the data should not be used for ads.
  final List<String> uses;

/// A list of paths, preferably URL without the scheme or reverse-DNS. 
/// 
/// Keep list short and use wildcard () matching. Prefix with NOT to invert.
  final List<String> paths;

  /// Builds a destination with [paths] and [uses]. Default to all uses.
  ///
  /// Example 1: destination with URL and "send user data" use.
  ///```
  /// TikiSdkDestination destination = TikiSdkDestination(
  ///   ["api.mycompany.com/v1/user"], uses: ["send user data"]
  /// )
  /// ````
  ///
  /// Example 2: destination with reverse-DNS and all uses
  ///```
  /// TikiSdkDestination destination = TikiSdkDestination(
  ///   ["com.mycompany.api"]
  /// )
  /// ````
  ///
  /// Example 3: destination with wildcard URL and NOT keyword in paths.
  ///```
  /// TikiSdkDestination destination = TikiSdkDestination(
  ///   ["api.mycompany.com/v1/user/*, NOT api.mycompany.com/v1/user/private]
  /// )
  /// ````
  const TikiSdkDestination(this.paths, {this.uses = const ["*"]});

  /// Builds a destination for all [paths] and [uses]
  const TikiSdkDestination.all()
      : paths = const ['*'],
        uses = const ['*'];

  /// Builds a destination with no [paths] nor [uses].
  ///
  /// This should be use to revoke all destinations for a specific origin.
  const TikiSdkDestination.none()
      : paths = const [],
        uses = const [];

  /// Converts the JSON representation of the destination into a TikiSdkDestination.
  ///
  /// This function converts a JSON string into a TikiSdkDestination object.
  /// The JSON string must follow the pattern of the default main constructor, 
  /// with paths being a required field. If paths is not present, a [NullThrownError] 
  /// will be thrown.
  /// The function builds a Map from the JSON string and then 
  /// calls [TikiSdkDestination.fromMap] to create the TikiSdkDestination object.
  static TikiSdkDestination fromJson(String jsonString) {
    Map jsonMap = jsonDecode(jsonString);
    Map<String, List<String>> destMap = {
      "paths": jsonMap["paths"]?.map<String>((e) => e.toString()).toList() ??
          NullThrownError(),
      "uses":
          jsonMap["uses"]?.map<String>((e) => e.toString()).toList() ?? ["*"],
    };
    return TikiSdkDestination.fromMap(destMap);
  }

  /// Converts a [Map<String, List<String>>] into a TikiSdkDestination.
  ///
  /// Sample Map:
  /// ```
  /// <String, List<String> {
  ///   "paths" : ["path_to_use", "NOT path_to_block"],
  ///   "uses"  : ["use case", "NOT not allowed use case"]
  /// }
  /// ```
  TikiSdkDestination.fromMap(Map<String, List<String>> map)
      : uses = map['uses'] ?? [],
        paths = map['paths'] ?? [];

  /// Serializes the destination as a byte array to be used in the blockchain.
  ///
  /// See [CompactSize.encode].
  Uint8List serialize() {
    return (BytesBuilder()
          ..add(CompactSize.encode(
              Uint8List.fromList(jsonEncode(paths).codeUnits)))
          ..add(CompactSize.encode(
              Uint8List.fromList(jsonEncode(uses).codeUnits))))
        .toBytes();
  }

  /// Deserializes a byte array into a destination.
  ///
  /// See [CompactSize.decode]
  static TikiSdkDestination deserialize(Uint8List serialized) {
    List<Uint8List> unserialized = CompactSize.decode(serialized);
    List<dynamic> paths = jsonDecode(String.fromCharCodes(unserialized[0]));
    List<dynamic> uses = jsonDecode(String.fromCharCodes(unserialized[1]));
    return TikiSdkDestination(paths.map<String>((e) => e.toString()).toList(),
        uses: uses.map<String>((e) => e.toString()).toList());
  }

  /// Creates the JSON representation of this.
  ///
  /// Uses overwritten [toString] method.
  String toJson() => toString();

  /// Creates the Map<String, List<String> representation of this.
  ///
  /// Sample Map:
  /// ```
  /// <String, List<String> {
  ///   "paths" : ["path_to_use", "NOT path_to_block"],
  ///   "uses"  : ["use case", "NOT not allowed use case"]
  /// }
  /// ```
  Map toMap() => {"paths": paths, "uses": uses};

  /// Converts to a JSON String.
  @override
  String toString() => jsonEncode({'uses': uses, 'paths': paths});
}
