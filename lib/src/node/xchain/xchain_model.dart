import '../../utils/json_object.dart';

class XchainModel {
  int? id;
  DateTime? lastChecked;
  String uri;
  String pubkey;

  XchainModel(
      {this.id, this.lastChecked, required this.uri, required this.pubkey});

  XchainModel.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        pubkey = map['pubkey'],
        lastChecked = map['last_checked'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['last_checked'] * 1000)
            : null,
        uri = map['uri'];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pubkey': pubkey,
      'last_checked': lastChecked,
      'uri': uri,
    };
  }

  @override
  String toString() {
    return '''XchainModel
      id: $id,
      'pubkey': $pubkey,
      last_checked: $lastChecked,
      uri: $uri,
    ''';
  }
}
