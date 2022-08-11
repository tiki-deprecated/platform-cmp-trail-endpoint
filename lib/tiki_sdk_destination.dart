class TikiSdkDestination {
  /// An optional list of application specific uses cases
  /// applicable to the given destination. Prefix with NOT
  /// to invert. _i.e. NOT ads
  List<String>? uses;

  /// A list of paths, preferably URL without the scheme or
  /// reverse FQDN. Keep list short and use wildcard (*)
  /// matching. Prefix with NOT to invert.
  /// _i.e. NOT mytiki.com/*
  List<String> paths;

  TikiSdkDestination(this.paths, {this.uses});
}