import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';
import 'package:tiki_sdk_dart/metadata/metadata_service.dart';

void main() {
  group('Metadata Tests', () {
    test('Save - Success', () {
      Database db = sqlite3.openInMemory();
      MetadataService metadataService = MetadataService(db);

      String version = '1.0';
      metadataService.save(MetadataKey.dbVersion, version);
    });

    test('Get - Success', () {
      Database db = sqlite3.openInMemory();
      MetadataService metadataService = MetadataService(db);
      metadataService.save(MetadataKey.dbVersion, '1.0');

      String version = metadataService.get(MetadataKey.dbVersion);
      expect(version, '1.0');
    });

    test('Update - Success', () {
      Database db = sqlite3.openInMemory();
      MetadataService metadataService = MetadataService(db);
      metadataService.save(MetadataKey.dbVersion, '1.0');

      String version = '2.0';
      metadataService.update(MetadataKey.dbVersion, version);
      String newVersion = metadataService.get(MetadataKey.dbVersion);
      expect(version, newVersion);
    });
  });
}
