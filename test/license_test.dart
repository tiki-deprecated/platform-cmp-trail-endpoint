import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';
import 'package:tiki_trail/tiki_trail.dart';
import 'package:uuid/uuid.dart';
import 'fixtures/in_mem.dart';

void main() async {
  TikiTrail tikiTrail = await InMemBuilders.tikiTrail();
  group('All method test', () {
    test('all - licenses - success', () async {
      String ptr = const Uuid().v4();
      String origin = 'com.myco.myapp';
      List<TitleTag> tags = [TitleTag.contacts(), TitleTag.audio()];
      String description = 'New Description';
      TitleRecord titleRecord = await tikiTrail.title
          .create(ptr, origin: origin, tags: tags, description: description);
      String terms = "This is a new term";
      List<LicenseUse> uses = [
        LicenseUse([LicenseUsecase.aiTraining()]),
        LicenseUse([LicenseUsecase.analytics()]),
      ];
      await tikiTrail.license
          .create(titleRecord, uses, terms, expiry: DateTime(1));
      await tikiTrail.license
          .create(titleRecord, uses, terms, expiry: DateTime(2));
      List<LicenseRecord> record = tikiTrail.license.all(titleRecord);
      expect(record.length, 2);
      expect(record.elementAt(0).expiry, DateTime(2));
      expect(record.elementAt(0).terms, terms);
      expect(record.elementAt(1).expiry, DateTime(1));
      expect(record.elementAt(1).terms, terms);
      expect(record.elementAt(0).uses.elementAt(0).usecases.elementAt(0).value,
          uses.elementAt(0).usecases.elementAt(0).value);
      expect(record.elementAt(0).uses.elementAt(1).usecases.elementAt(0).value,
          uses.elementAt(1).usecases.elementAt(0).value);
    });

    test('all - license - invalid - title - success', () async {
      String invalidPTR = const Uuid().v4();
      TitleRecord titleRecord = await tikiTrail.title
          .create(invalidPTR, origin: "com.myco.myapp");
      List<LicenseRecord> invalidRecord = tikiTrail.license.all(titleRecord);
      expect(invalidRecord, []);
    });

    test('all - license - for - title - no - licenses - success', () async {
      String ptr = const Uuid().v4();
      String origin = 'com.myco.myapp';
      List<TitleTag> tags = [TitleTag.contacts(), TitleTag.audio()];
      String description = 'New Description';
      TitleRecord titleRecord = await tikiTrail.title.create(ptr,
          origin: origin, tags: tags, description: description);
      List<LicenseRecord> record =
          tikiTrail.license.all(titleRecord);
      expect(record, []);
    });
  });
}
