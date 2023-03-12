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
      expect(syncedTxns?.length, 3);
      expect(Bytes.base64UrlEncode(syncedBlock!.id!),
          'eBhsjwopFAC3-ybuVUvo2lkIfGLTB4PnPmWKBkUoV4M');
      expect(syncedBlock?.version, 1);
      expect(Bytes.base64UrlEncode(syncedBlock!.transactionRoot),
          '_ArUHdfhVNxux9OKdxa0A3zLnLGqFSs_Yn8XKaPcciQ');
      expect(Bytes.base64UrlEncode(syncedBlock!.previousHash), 'AA');
      expect(syncedBlock?.timestamp.millisecondsSinceEpoch, 1676493019000);
      expect(Bytes.base64UrlEncode(syncedTxns!.elementAt(0).id!),
          'x-ZeyVQBs1sS34DFyzLZCCXib9lOgtHYseRi0K4bFoA');
      expect(Bytes.base64UrlEncode(syncedTxns!.elementAt(1).id!),
          'P6i-1oibc4QXQkkwGYdAXt4UGLNnfxc1fVlpX9o13OU');
      expect(Bytes.base64UrlEncode(syncedTxns!.elementAt(2).id!),
          '-yNtsrHDKHtKJnRGymbduxN3z4c3ztz3ujbeVd_qtfA');
      expect(Bytes.base64UrlEncode(syncedTxns!.elementAt(0).block!.id!),
          'eBhsjwopFAC3-ybuVUvo2lkIfGLTB4PnPmWKBkUoV4M');
      expect(syncedTxns!.elementAt(0).version, 1);
      expect(syncedTxns!.elementAt(0).timestamp.millisecondsSinceEpoch,
          1676492959000);
      expect(Bytes.base64UrlEncode(syncedTxns!.elementAt(0).address),
          xChainNock.address);
      expect(Bytes.base64UrlEncode(syncedTxns!.elementAt(0).signature!),
          'Ltp9hf-OvBizDsLzAiwwFZ6PP88Efc3GzuOrhd2IVpXA8DI3YHxJseJxsMZh5gV2fzVfZe25jm6uuPz7xFHmWO60e-LTmT2SB4-RBHR83YCB0V1J3d6hvYhfhGKP-GQ-7o9-alJXnxaaCiAfx7Xy7PuhZsM30UfpEHiJp4aO4n0oSHfRvnrQHN151JFdaVqmh0woPZFAHUsbknp2iDieujQLtoU0jhZjZYo3qTauru4yRYSqxoVw_cXL4Kt-KPspQwaMicQA1u56o2JkVwf-MWkbGuJWChdSVKYVbYO0AYg-kdgx1RUo1fUQuGgEVt1hm4be6BxBr8msAd4tJXO-8w');
      expect(syncedTxns!.elementAt(0).assetRef, '\x00');
    });
  });
}
