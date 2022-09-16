/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */
/// {@category Node}

import 'dart:io';
/// [HttpException] for expired expired policy.
class WasabiExceptionExpired extends HttpException {
  WasabiExceptionExpired(super.message);
}
