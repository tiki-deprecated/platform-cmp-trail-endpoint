/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:tiki_idp/tiki_idp.dart';
import 'package:tiki_trail/key.dart';
import 'package:uuid/uuid.dart';

import 'in_mem.dart';

String id = const Uuid().v4();
TikiIdp idp = TikiIdp([], '', InMemKeyStorage());

Future<Key> get key async {
  await idp.key(id);
  return Key.pem(id, await idp.export(id));
}
