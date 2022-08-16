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
      : xchainId = map['id'],
        lastChecked = map['last_checked'] != null ? 
          DateTime.fromMillisecondsSinceEpoch(map['last_checked']*1000) : null,
        uri = map['uri'];

  Map<String, dynamic> toMap() {
    return {
      'id': xchainId,
      'last_checked': lastChecked,
      'uri': uri,
    };
  }

  String toSqlValues() {
    return "$xchainId, $lastChecked, '$uri'";
  }

  @override
  String toString() {
    return '''XchainModel
      id: $xchainId,
      last_checked: $lastChecked,
      uri: $uri,
    ''';
  }
}
