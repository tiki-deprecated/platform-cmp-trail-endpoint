/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */
/// {@category SDK}
/// The type of data a stream, point or pool holds.
enum TikiSdkDataTypeEnum {
  emailAddress('email_address');

  const TikiSdkDataTypeEnum(this.val);

  final String val;
}
