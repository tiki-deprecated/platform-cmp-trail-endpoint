/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */
import 'dart:convert';

/// {@category SDK}
/// The destination to which the data is consented to be used.
class TikiSdkDestination {
  /// An optional list of application specific uses cases
  /// applicable to the given destination. Prefix with NOT
  /// to invert. _i.e. NOT ads
  List<String>? uses;

  /// A list of paths, preferably URL without the scheme or
  /// reverse FQDN. Keep list short and use wildcard (*)
  /// matching. Prefix with NOT to invert.
  /// _i.e. NOT mytiki.com/*
  late List<String> paths;

  TikiSdkDestination(this.paths, {this.uses});

  TikiSdkDestination.fromJson(String jsonString) {
    Map map = jsonDecode(jsonString);
    uses = uses == null ? null : map['uses'].cast<String>();
    paths = map['paths'].cast<String>();
  }

  @override
  String toString() => jsonEncode({'uses': uses, 'paths': paths});
}
