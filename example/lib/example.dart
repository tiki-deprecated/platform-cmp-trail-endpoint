/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:io';

import 'package:example/in_mem_key_storage.dart';
import 'package:sqlite3/common.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:tiki_idp/tiki_idp.dart';
import 'package:tiki_trail/key.dart';
import 'package:tiki_trail/tiki_trail.dart';
import 'package:uuid/uuid.dart';

void main(List<String> arguments) async {
  InMemKeyStorage keyStorage = InMemKeyStorage();
  CommonDatabase database = sqlite3.openInMemory();

  String id = Uuid().v4();
  String ptr = const Uuid().v4();
  TikiIdp idp = TikiIdp([], 'PUBLISHING_ID', keyStorage);

  Key key = await TikiTrail.withId(id, idp);
  TikiTrail tiki = await TikiTrail.init(
      'PUBLISHING_ID', 'com.mytiki.tiki_trail.example', idp, key, database);

  TitleRecord title = await tiki.title.create(ptr, tags: [TitleTag.userId()]);
  print("Title Record created with id ${title.id} for ptr: $ptr");

  LicenseRecord license = await tiki.license.create(
      title,
      [
        LicenseUse([LicenseUsecase.attribution()])
      ],
      'terms');
  print(
      "License Record created with id ${license.id} for title: ${license.title.id}");

  tiki.guard(ptr, [LicenseUsecase.attribution()],
      onPass: () => print("There is a valid license for usecase attribution."));

  tiki.guard(ptr, [LicenseUsecase.support()],
      onFail: (cause) => print(
          "There is not a valid license for usecase support. Cause: $cause"));

  exit(0);
}
