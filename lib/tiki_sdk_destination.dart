/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */
import 'dart:convert';
import 'dart:typed_data';

import 'utils/compact_size.dart';

/// {@category SDK}
/// The destination to which the data is consented to be used.
class TikiSdkDestination {
  /// An optional list of application specific uses cases
  /// applicable to the given destination. Prefix with NOT
  /// to invert. _i.e. NOT ads
  final List<String> uses;

  /// A list of paths, preferably URL without the scheme or
  /// reverse FQDN. Keep list short and use wildcard (*)
  /// matching. Prefix with NOT to invert.
  /// _i.e. NOT mytiki.com/*
  final List<String> paths;

  const TikiSdkDestination(this.paths, {this.uses = const []});

  const TikiSdkDestination.all()
      : paths = const ['*'],
        uses = const ['*'];

  const TikiSdkDestination.none()
      : paths = const [],
        uses = const [];

  static TikiSdkDestination fromJson(String jsonString) =>
      TikiSdkDestination.fromMap(jsonDecode(jsonString));

  TikiSdkDestination.fromMap(Map map)
      : uses = map['uses'] == null ? [] : [...map['uses']],
        paths = [...map['paths']];

  @override
  String toString() => jsonEncode({'uses': uses, 'paths': paths});

  Uint8List serialize() {
    return (BytesBuilder()
          ..add(CompactSize.encode(
              Uint8List.fromList(jsonEncode(paths).codeUnits)))
          ..add(CompactSize.encode(
              Uint8List.fromList(jsonEncode(uses).codeUnits))))
        .toBytes();
  }

  static TikiSdkDestination deserialize(Uint8List serialized) {
    List<Uint8List> unserialized = CompactSize.decode(serialized);
    return TikiSdkDestination(jsonDecode(String.fromCharCodes(unserialized[0])),
        uses: jsonDecode(String.fromCharCodes(unserialized[0])));
  }
}
