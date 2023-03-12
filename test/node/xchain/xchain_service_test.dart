/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:nock/nock.dart';
import 'package:sqlite3/common.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';
import 'package:tiki_sdk_dart/l0/auth/auth_service.dart';
import 'package:tiki_sdk_dart/l0/storage/storage_service.dart';
import 'package:tiki_sdk_dart/node/block/block_model.dart';
import 'package:tiki_sdk_dart/node/transaction/transaction_model.dart';
import 'package:tiki_sdk_dart/node/xchain/xchain_service.dart';
import 'package:tiki_sdk_dart/utils/bytes.dart';
import 'package:tiki_sdk_dart/utils/rsa/rsa.dart';
import 'package:tiki_sdk_dart/utils/rsa/rsa_private_key.dart';

import '../../l0/auth/auth_nock.dart';
import '../../l0/storage/storage_nock.dart';
import 'xchain_nock.dart';

void main() {
  setUpAll(() => nock.init());
  setUp(() => nock.cleanAll());

  group('XChain Service tests', () {
    test('Sync - Success', () async {
      RsaPrivateKey privateKey = Rsa.generate().privateKey;
      AuthNock authNock = AuthNock();

      authNock.interceptor;
      StorageNock storageNock = StorageNock();
      XChainNock xChainNock = XChainNock();
      storageNock.urnPrefix = '${xChainNock.appId}/${xChainNock.address}';
      storageNock.tokenInterceptor;
      storageNock.urnPrefix.split("/").first;
      final pkvIntercept = xChainNock.pkvInterceptor;
      final pkIntercept = xChainNock.pkInterceptor;
      final bvIntercept = xChainNock.bvInterceptor;
      final bIntercept = xChainNock.bInterceptor;
      final listIntercept = xChainNock.listInterceptor;

      StorageService storageService =
          StorageService(privateKey, AuthService(authNock.clientId));
      CommonDatabase database = sqlite3.openInMemory();
      XChainService service = XChainService(storageService, database);

      BlockModel? syncedBlock;
      List<TransactionModel>? syncedTxns;
      await service.sync(xChainNock.address,
          (BlockModel block, List<TransactionModel> txns) {
        syncedBlock = block;
        syncedTxns = txns;
      });
      expect(pkvIntercept.isDone, true);
      expect(pkIntercept.isDone, true);
      expect(bIntercept.isDone, true);
      expect(bvIntercept.isDone, true);
      expect(listIntercept.isDone, true);
      expect(syncedTxns?.length, 1);
      expect(Bytes.base64UrlEncode(syncedBlock!.id!),
          '2jPH00bX27QFlbJDynobsTHMQ71_kVWJbKVbuJMGTYI');
      expect(syncedBlock?.version, 1);
      expect(Bytes.base64UrlEncode(syncedBlock!.transactionRoot),
          '1CQMYKYtO9Bt2DnexUWNL3gSvs6kPKIxY84gYovUJM4');
      expect(Bytes.base64UrlEncode(syncedBlock!.previousHash),
          'XO99p1jVEfpQoSnGnLy42h0NXgoDXJ428CaEI9p9ZtY');
      expect(syncedBlock?.timestamp.millisecondsSinceEpoch, 1678594781000);
      expect(Bytes.base64UrlEncode(syncedTxns!.elementAt(0).id!),
          'mQyDnlU0LkUKiQnvIGUubEsxomWrTJ3CrKHqOPM13rc');
      expect(Bytes.base64UrlEncode(syncedTxns!.elementAt(0).block!.id!),
          '2jPH00bX27QFlbJDynobsTHMQ71_kVWJbKVbuJMGTYI');
      expect(syncedTxns!.elementAt(0).version, 2);
      expect(syncedTxns!.elementAt(0).timestamp.millisecondsSinceEpoch,
          1678594781000);
      expect(Bytes.base64UrlEncode(syncedTxns!.elementAt(0).address),
          xChainNock.address);
      expect(Bytes.base64UrlEncode(syncedTxns!.elementAt(0).userSignature!),
          'QO6y-6uh8KJc4u-1AAWOS4mur2FpUb4My1mYDsG3Odt4Oi-fIZxJO_MqZ9DNC6_Y1Fc6_Fnarh04_7-5HKmr-1sT-D8aQyFnm41Lop3TBtH4tfsFZSHN_rO-bJ5ICRwrdqJwhBabW9K35f4x8rWm11oBJFDNCNVd-S1DNt4CVlE_DRI76Fna1JTRq0doG8TPt3Y4FW5X77aB-hZZwbZOcDCe2vYUxvCZT2fLYEOkjR3Qke-_iCrXUSODPJ8rkHVA1rgf2iRYVpN9H3KX6RAT4IcSdPOZlsWrF7yhXDplJqLQHqRjW6OZBSg3s_3TJ4ekbkruxhZx7KugWhu6sFAe9Q');
      expect(syncedTxns!.elementAt(0).assetRef,
          'txn://4QlIHwMZYjcFv5ZmORsTxXyZLOOfmiSUUb5MgCjdrUE');
    });
  });
}
