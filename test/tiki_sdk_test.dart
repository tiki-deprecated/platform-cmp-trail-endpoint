/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:test/test.dart';

void main() {
  group('TIKI SDK tests', () {
    // test('SDK initialization', () async {
    //   InMemTikiSdkBuilder sdkBuilder = InMemTikiSdkBuilder();
    //   sdkBuilder.origin('com.mytiki.sdk.dart.test');
    //   await sdkBuilder.build();
    //   expect(1, 1);
    // });
    // test('create ownership', () async {
    //   InMemTikiSdkBuilder sdkBuilder = InMemTikiSdkBuilder();
    //   sdkBuilder.origin('com.mytiki.sdk.dart.test');
    //   TikiSdk tikiSdk = await sdkBuilder.build();
    //   await tikiSdk
    //       .assignOwnership('test', TikiSdkDataTypeEnum.point, ['email']);
    //   expect(1, 1);
    // });
    // test('give and revoke consent', () async {
    //   InMemTikiSdkBuilder sdkBuilder = InMemTikiSdkBuilder();
    //   sdkBuilder.origin('com.mytiki.sdk.dart.test');
    //   TikiSdk tikiSdk = await sdkBuilder.build();
    //   String ownershipId = await tikiSdk
    //       .assignOwnership('test', TikiSdkDataTypeEnum.point, ['email']);
    //   await tikiSdk.modifyConsent(ownershipId, const TikiSdkDestination.all());
    //   ConsentModel? consentGiven = tikiSdk.getConsent('test');
    //   expect(consentGiven!.destination.uses[0], "*");
    //   expect(consentGiven.destination.paths[0], "*");
    //   await tikiSdk.modifyConsent(ownershipId, const TikiSdkDestination.none());
    //   consentGiven = tikiSdk.getConsent('test');
    //   expect(consentGiven!.destination.uses.isEmpty, true);
    //   expect(consentGiven.destination.paths.isEmpty, true);
    // });
    // test('expire consent', () async {
    //   bool ok = false;
    //   InMemTikiSdkBuilder sdkBuilder = InMemTikiSdkBuilder();
    //   sdkBuilder.origin('com.mytiki.sdk.dart.test');
    //   TikiSdk tikiSdk = await sdkBuilder.build();
    //   String ownershipId = await tikiSdk
    //       .assignOwnership('test', TikiSdkDataTypeEnum.point, ['email']);
    //   await tikiSdk.modifyConsent(ownershipId, const TikiSdkDestination.all());
    //   await tikiSdk.applyConsent(
    //       'test', const TikiSdkDestination.all(), () => ok = true);
    //   expect(ok, true);
    //   await tikiSdk.modifyConsent(ownershipId, const TikiSdkDestination.all(),
    //       expiry: DateTime.now());
    //   await tikiSdk.applyConsent(
    //       'test', const TikiSdkDestination.all(), () => ok = true,
    //       onBlocked: (_) => ok = false);
    //   expect(ok, false);
    // });
    // test('run a function based on user consent', () async {
    //   bool ok = false;
    //   InMemTikiSdkBuilder sdkBuilder = InMemTikiSdkBuilder();
    //   sdkBuilder.origin('com.mytiki.sdk.dart.test');
    //   TikiSdk tikiSdk = await sdkBuilder.build();
    //   String ownershipId = await tikiSdk
    //       .assignOwnership('test', TikiSdkDataTypeEnum.point, ['email']);
    //   await tikiSdk.modifyConsent(ownershipId, const TikiSdkDestination.all());
    //   ConsentModel? consentGiven = tikiSdk.getConsent('test');
    //   expect(consentGiven!.destination.uses[0], "*");
    //   expect(consentGiven.destination.paths[0], "*");
    //   await tikiSdk.applyConsent(
    //       'test', const TikiSdkDestination.all(), () => ok = true);
    //   expect(ok, true);
    // });
    // test('run a function based on specific destination path', () async {
    //   bool ok = false;
    //   InMemTikiSdkBuilder sdkBuilder = InMemTikiSdkBuilder();
    //   sdkBuilder.origin('com.mytiki.sdk.dart.test');
    //   TikiSdk tikiSdk = await sdkBuilder.build();
    //   String ownershipId = await tikiSdk
    //       .assignOwnership('test', TikiSdkDataTypeEnum.point, ['email']);
    //   await tikiSdk.modifyConsent(
    //       ownershipId, const TikiSdkDestination(["mypath/allowed"]));
    //   ConsentModel? consentGiven = tikiSdk.getConsent('test');
    //   expect(consentGiven!.destination.uses[0], "*");
    //   expect(consentGiven.destination.paths[0], "mypath/allowed");
    //   await tikiSdk.applyConsent('test',
    //       const TikiSdkDestination(["mypath/allowed"]), () => ok = true);
    //   expect(ok, true);
    // });
    // test('block a function based on specific destination path', () async {
    //   bool ok = true;
    //   InMemTikiSdkBuilder sdkBuilder = InMemTikiSdkBuilder();
    //   sdkBuilder.origin('com.mytiki.sdk.dart.test');
    //   TikiSdk tikiSdk = await sdkBuilder.build();
    //   String ownershipId = await tikiSdk
    //       .assignOwnership('test', TikiSdkDataTypeEnum.point, ['email']);
    //   await tikiSdk.modifyConsent(
    //       ownershipId, const TikiSdkDestination(["mypath/allowed"]));
    //   ConsentModel? consentGiven = tikiSdk.getConsent('test');
    //   expect(consentGiven!.destination.uses[0], "*");
    //   expect(consentGiven.destination.paths[0], "mypath/allowed");
    //   await tikiSdk.applyConsent('test',
    //       const TikiSdkDestination(["mypath/not_allowed"]), () => ok = true,
    //       onBlocked: (_) => ok = false);
    //   expect(ok, false);
    // });
    // test('run a function based on wildcard destination path', () async {
    //   bool ok = false;
    //   InMemTikiSdkBuilder sdkBuilder = InMemTikiSdkBuilder();
    //   sdkBuilder.origin('com.mytiki.sdk.dart.test');
    //   TikiSdk tikiSdk = await sdkBuilder.build();
    //   String ownershipId = await tikiSdk
    //       .assignOwnership('test', TikiSdkDataTypeEnum.point, ['email']);
    //   await tikiSdk.modifyConsent(
    //       ownershipId, const TikiSdkDestination(["mypath/*"]));
    //   ConsentModel? consentGiven = tikiSdk.getConsent('test');
    //   expect(consentGiven!.destination.uses[0], "*");
    //   expect(consentGiven.destination.paths[0], "mypath/*");
    //   await tikiSdk.applyConsent(
    //       'test',
    //       const TikiSdkDestination(["mypath/some_other_path"]),
    //           () => ok = true);
    //   expect(ok, true);
    // });
    // test('block a function based on wildcard destination path', () async {
    //   bool ok = true;
    //   InMemTikiSdkBuilder sdkBuilder = InMemTikiSdkBuilder();
    //   sdkBuilder.origin('com.mytiki.sdk.dart.test');
    //   TikiSdk tikiSdk = await sdkBuilder.build();
    //   String ownershipId = await tikiSdk
    //       .assignOwnership('test', TikiSdkDataTypeEnum.point, ['email']);
    //   await tikiSdk.modifyConsent(
    //       ownershipId, const TikiSdkDestination(["mypath/allowed/*"]));
    //   ConsentModel? consentGiven = tikiSdk.getConsent('test');
    //   expect(consentGiven!.destination.uses[0], "*");
    //   expect(consentGiven.destination.paths[0], "mypath/allowed/*");
    //   await tikiSdk.applyConsent('test',
    //       const TikiSdkDestination(["mypath/not_allowed"]), () => ok = true,
    //       onBlocked: (_) => ok = false);
    //   expect(ok, false);
    // });
    // test('block a function based on NOT keyword destination path', () async {
    //   bool ok = true;
    //   InMemTikiSdkBuilder sdkBuilder = InMemTikiSdkBuilder();
    //   sdkBuilder.origin('com.mytiki.sdk.dart.test');
    //   TikiSdk tikiSdk = await sdkBuilder.build();
    //   String ownershipId = await tikiSdk
    //       .assignOwnership('test', TikiSdkDataTypeEnum.point, ['email']);
    //   await tikiSdk.modifyConsent(
    //       ownershipId,
    //       const TikiSdkDestination(
    //           ["mypath/allowed/*", "NOT mypath/allowed/not"]));
    //   ConsentModel? consentGiven = tikiSdk.getConsent('test');
    //   expect(consentGiven!.destination.uses[0], "*");
    //   expect(consentGiven.destination.paths[0], "mypath/allowed/*");
    //   expect(consentGiven.destination.paths[1], "NOT mypath/allowed/not");
    //   await tikiSdk.applyConsent('test',
    //       const TikiSdkDestination(["mypath/allowed/not"]), () => ok = true,
    //       onBlocked: (_) => ok = false);
    //   expect(ok, false);
    // });
    // test('run a function based on specific use', () async {
    //   bool ok = false;
    //   InMemTikiSdkBuilder sdkBuilder = InMemTikiSdkBuilder();
    //   sdkBuilder.origin('com.mytiki.sdk.dart.test');
    //   TikiSdk tikiSdk = await sdkBuilder.build();
    //   String ownershipId = await tikiSdk
    //       .assignOwnership('test', TikiSdkDataTypeEnum.point, ['email']);
    //   await tikiSdk.modifyConsent(
    //       ownershipId, const TikiSdkDestination(["*"], uses: ["allowed_use"]));
    //   ConsentModel? consentGiven = tikiSdk.getConsent('test');
    //   expect(consentGiven!.destination.uses[0], "allowed_use");
    //   expect(consentGiven.destination.paths[0], "*");
    //   await tikiSdk.applyConsent(
    //       'test',
    //       const TikiSdkDestination(["mypath/allowed"], uses: ["allowed_use"]),
    //           () => ok = true);
    //   expect(ok, true);
    // });
    // test('block a function based on specific destination path', () async {
    //   bool ok = true;
    //   InMemTikiSdkBuilder sdkBuilder = InMemTikiSdkBuilder();
    //   sdkBuilder.origin('com.mytiki.sdk.dart.test');
    //   TikiSdk tikiSdk = await sdkBuilder.build();
    //   String ownershipId = await tikiSdk
    //       .assignOwnership('test', TikiSdkDataTypeEnum.point, ['email']);
    //   await tikiSdk.modifyConsent(
    //       ownershipId, const TikiSdkDestination(["*"], uses: ["allowed_use"]));
    //   ConsentModel? consentGiven = tikiSdk.getConsent('test');
    //   expect(consentGiven!.destination.uses[0], "allowed_use");
    //   expect(consentGiven.destination.paths[0], "*");
    //   await tikiSdk.applyConsent(
    //       'test',
    //       const TikiSdkDestination(["mypath/allowed"], uses: ["not_allowed"]),
    //           () => ok = true,
    //       onBlocked: (_) => ok = false);
    //   expect(ok, false);
    // });
    // test('run a function based on wildcard use', () async {
    //   bool ok = false;
    //   InMemTikiSdkBuilder sdkBuilder = InMemTikiSdkBuilder();
    //   sdkBuilder.origin('com.mytiki.sdk.dart.test');
    //   TikiSdk tikiSdk = await sdkBuilder.build();
    //   String ownershipId = await tikiSdk
    //       .assignOwnership('test', TikiSdkDataTypeEnum.point, ['email']);
    //   await tikiSdk.modifyConsent(ownershipId,
    //       const TikiSdkDestination(["*"], uses: ["allowed_use", "*"]));
    //   ConsentModel? consentGiven = tikiSdk.getConsent('test');
    //   expect(consentGiven!.destination.uses[0], "allowed_use");
    //   expect(consentGiven.destination.paths[0], "*");
    //   await tikiSdk.applyConsent(
    //       'test',
    //       const TikiSdkDestination(["mypath/allowed"], uses: ["another_use"]),
    //           () => ok = true);
    //   expect(ok, true);
    // });
    // test('block a function based on NOT keyword destination path', () async {
    //   bool ok = true;
    //   InMemTikiSdkBuilder sdkBuilder = InMemTikiSdkBuilder();
    //   sdkBuilder.origin('com.mytiki.sdk.dart.test');
    //   TikiSdk tikiSdk = await sdkBuilder.build();
    //   String ownershipId = await tikiSdk
    //       .assignOwnership('test', TikiSdkDataTypeEnum.point, ['email']);
    //   await tikiSdk.modifyConsent(
    //       ownershipId,
    //       const TikiSdkDestination(["*"],
    //           uses: ["allowed_use", "NOT another_use"]));
    //   ConsentModel? consentGiven = tikiSdk.getConsent('test');
    //   expect(consentGiven!.destination.uses[0], "allowed_use");
    //   expect(consentGiven.destination.paths[0], "*");
    //   await tikiSdk.applyConsent(
    //       'test',
    //       const TikiSdkDestination(["mypath/allowed"], uses: ["another_use"]),
    //           () => ok = true,
    //       onBlocked: (_) => ok = false);
    //   expect(ok, false);
    // });
  });
}
