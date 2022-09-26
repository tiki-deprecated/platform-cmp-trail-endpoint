import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';
import 'package:tiki_sdk_dart/consent/consent_repository.dart';
import 'package:tiki_sdk_dart/consent/cosent_model.dart';
import 'package:tiki_sdk_dart/ownership/ownership_model.dart';
import 'package:tiki_sdk_dart/tiki_sdk.dart';

void main() {
  group('Consent Tests', () {
      OwnershipModel ownershipModel = OwnershipModel(
          transactionId: 'random1',
          source: 'tiki app',
          types: [TikiSdkDataTypeEnum.emailAddress],
          origin: 'com.mytiki.test');
      OwnershipModel ownershipModel2 = OwnershipModel(
          transactionId: 'random2',
          source: 'tiki desktop',
          types: [TikiSdkDataTypeEnum.emailAddress],
          origin: 'com.mytiki.test');
      OwnershipModel ownershipModel3 = OwnershipModel(
          transactionId: 'random3',
          source: 'tiki sdk',
          types: [TikiSdkDataTypeEnum.emailAddress],
          origin: 'com.mytiki.test');
      TikiSdkDestination destination = TikiSdkDestination(['com.mytiki/*']);
    test('Repository tests. Save and get by assetRef', () {
      Database db = sqlite3.openInMemory();
      ConsentRepository repository = ConsentRepository(db);
      ConsentModel consentModel = ConsentModel(
        ownershipModel.transactionId!, destination,
        about: 'test 1',
        reward: '1 point');
      ConsentModel consentModel2 = ConsentModel(
        ownershipModel2.transactionId!, destination,
        about: 'test 2',
        reward: '2 points');
      ConsentModel consentModel3 = ConsentModel(
        ownershipModel3.transactionId!, destination,
        about: 'test 3',
        reward: '3 points');
      repository.save(consentModel);
      repository.save(consentModel2);
      repository.save(consentModel3);
      List<ConsentModel> consents = repository.getByOwnership(ownershipModel);
      List<ConsentModel> consents2 = repository.getByOwnership(ownershipModel2);
      List<ConsentModel> consents3 = repository.getByOwnership(ownershipModel3);
      expect(consents.length, 1);
      expect(consents[0].reward, '1 point');
      expect(consents2.length, 1);
      expect(consents2[0].reward, '2 points');
      expect(consents3.length, 1);
      expect(consents3[0].reward, '3 points');
    });

  });
}
