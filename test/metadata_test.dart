import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';
import 'package:tiki_sdk_dart/src/metadata/metadata_key.dart';
import 'package:tiki_sdk_dart/src/metadata/metadata_service.dart';

void main() {
  group('metdata test', () {
    Database db = sqlite3.openInMemory();
    MetadataService metadataService = MetadataService(db);
    test('save metadata', () {
      String version = '1.0';
      metadataService.save(MetadataKey.dbVersion, version);
      expect(1, 1);
    });
    test('get metadata', () {
      String version = metadataService.get(MetadataKey.dbVersion);
      expect(version, '1.0');
    });
    test('update metadata', () {
      String version = '2.0';
      metadataService.update(MetadataKey.dbVersion, version);
      String newVersion = metadataService.get(MetadataKey.dbVersion);
      expect(version, newVersion);
    });
  });
}
