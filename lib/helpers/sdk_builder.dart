import '../node/key/key_storage.dart';
import '../tiki_sdk.dart' show TikiSdk;

abstract class SdkBuilder {
  void origin(String origin);
  void keyStorage(KeyStorage keyStorage);
  void databaseDir(String databaseDir);
  void publishingId(String? publishingId);
  void address(String? address);
  Future<TikiSdk> build();

  @override
  noSuchMethod(Invocation invocation) => "got ${invocation.memberName} "
      "with arguments ${invocation.positionalArguments}";
}
