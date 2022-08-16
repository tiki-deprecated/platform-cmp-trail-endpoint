class XchainModel {
  int? xchainId;
  DateTime? lastChecked;
  String uri;

  XchainModel({
    this.xchainId,
    this.lastChecked,
    required this.uri,
  });

  XchainModel.fromMap(Map<String, dynamic> map)
      : xchainId = map['xchainId'],
        lastChecked = map['lastChecked'],
        uri = map['uri'];

  Map<String, dynamic> toMap() {
    return {
      'xchain_id': xchainId,
      'last_checked': lastChecked,
      'uri': uri,
    };
  }

  String toSqlValues() {
    return '$xchainId, $lastChecked, $uri';
  }

  @override
  String toString() {
    return '''XchainModel
      xchain_id: $xchainId,
      last_checked: $lastChecked,
      uri: $uri,
    ''';
  }
}
