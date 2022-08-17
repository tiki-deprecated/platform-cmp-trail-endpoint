class XchainModel {
  int? id;
  DateTime? lastChecked;
  String uri;

  XchainModel({
    this.id,
    this.lastChecked,
    required this.uri,
  });

  XchainModel.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        lastChecked = map['last_checked'] != null ? 
          DateTime.fromMillisecondsSinceEpoch(map['last_checked']*1000) : null,
        uri = map['uri'];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'last_checked': lastChecked,
      'uri': uri,
    };
  }

  String toSqlValues() {
    return "$id, $lastChecked, '$uri'";
  }

  @override
  String toString() {
    return '''XchainModel
      id: $id,
      last_checked: $lastChecked,
      uri: $uri,
    ''';
  }
}
