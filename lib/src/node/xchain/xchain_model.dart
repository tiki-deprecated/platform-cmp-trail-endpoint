class XchainModel {
  String address;
  String pubkey;
  DateTime? lastChecked;

  XchainModel({required this.address, required this.pubkey, this.lastChecked});

  XchainModel.fromMap(Map<String, dynamic> map)
      : address = map['address'],
        pubkey = map['pubkey'],
        lastChecked = map['last_checked'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['last_checked'] * 1000)
            : null;
  
  @override
  String toString() {
    return '''XchainModel
      address: $address,
      'pubkey': $pubkey,
      last_checked: $lastChecked,
    ''';
  }
}
