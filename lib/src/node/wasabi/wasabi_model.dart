class WasabiModel<T> {
  final String id;
  final String signature;
  final DateTime timestamp;
  final T payload;

  WasabiModel({
    required this.id,
    required this.signature,
    required this.timestamp,
    required this.payload,
  });

  // WasabiModel.fromJson(String? dataStr){
  //   id = ;
  //   signature = ;
  //   timestamp = ;
  //   payload = ;
  // }

}
