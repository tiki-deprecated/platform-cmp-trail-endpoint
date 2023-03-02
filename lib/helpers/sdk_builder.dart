import '../node/key/key_storage.dart';
import '../tiki_sdk.dart' show TikiSdk;

class SdkBuilder {
  String? _origin;
  KeyStorage? _keyStorage;
  String? _databaseDir;
  String? _publishingId;
  String? _address;

  void origin(String origin) => _origin = origin;
  void keyStorage(KeyStorage keyStorage) => _keyStorage = keyStorage;
  void databaseDir(String databaseDir) => _databaseDir = databaseDir;
  void publishingId(String? publishingId) => _publishingId = publishingId;
  void address(String? address) => _address = address;
  Future<TikiSdk> build();

  @override
  noSuchMethod(Invocation msg) => "got ${msg.memberName} "
      "with arguments ${msg.positionalArguments}";
}
