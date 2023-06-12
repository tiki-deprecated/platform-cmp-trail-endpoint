/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:test/test.dart';
import 'package:tiki_trail/tiki_trail.dart';
import 'package:tiki_trail/utils/guard.dart';

void main() {
  LicenseRecord fakeLicense(List<LicenseUse> uses, {DateTime? expiry}) {
    return LicenseRecord('dummy', TitleRecord('dummy', 'dummy'), uses, 'dummy',
        expiry: expiry);
  }

  group('TIKI SDK Guard tests', () {
    test('no uses - False', () async {
      List<LicenseUse> uses = [];
      bool pass = Guard.check(fakeLicense(uses), uses) == null;
      expect(pass, false);
    });

    test('expired - False', () async {
      List<LicenseUse> uses = [];
      bool pass = Guard.check(
              fakeLicense(uses,
                  expiry: DateTime.now().subtract(const Duration(hours: 1))),
              uses) ==
          null;
      expect(pass, false);
    });

    test('not expired - True', () async {
      List<LicenseUse> uses = [
        LicenseUse([LicenseUsecase.custom('test')])
      ];
      bool pass = Guard.check(
              fakeLicense(uses,
                  expiry: DateTime.now().add(const Duration(hours: 1))),
              uses) ==
          null;
      expect(pass, true);
    });

    test('valid usecase - True', () async {
      List<LicenseUse> uses = [
        LicenseUse([LicenseUsecase.custom('test')])
      ];
      bool pass = Guard.check(fakeLicense(uses), uses) == null;
      expect(pass, true);
    });

    test('invalid usecase - False', () async {
      List<LicenseUse> uses = [
        LicenseUse([LicenseUsecase.custom('test')])
      ];
      bool pass = Guard.check(fakeLicense(uses), [
            LicenseUse([LicenseUsecase.custom('block me')])
          ]) ==
          null;
      expect(pass, false);
    });

    test('multiple valid usecase - True', () async {
      List<LicenseUse> uses = [
        LicenseUse(
            [LicenseUsecase.custom('test1'), LicenseUsecase.custom('test2')]),
        LicenseUse([LicenseUsecase.custom('test3')])
      ];
      bool pass = Guard.check(fakeLicense(uses), [
            LicenseUse([
              LicenseUsecase.custom('test1'),
              LicenseUsecase.custom('test3')
            ])
          ]) ==
          null;
      expect(pass, true);
    });

    test('multiple invalid usecase - False', () async {
      List<LicenseUse> uses = [
        LicenseUse(
            [LicenseUsecase.custom('test1'), LicenseUsecase.custom('test2')]),
        LicenseUse([LicenseUsecase.custom('test3')])
      ];
      bool pass = Guard.check(fakeLicense(uses), [
            LicenseUse([
              LicenseUsecase.custom('block me'),
              LicenseUsecase.custom('test3')
            ])
          ]) ==
          null;
      expect(pass, false);
    });

    test('valid destination - True', () async {
      List<LicenseUse> uses = [
        LicenseUse([LicenseUsecase.custom('test')],
            destinations: ['\\.mytiki\\.com'])
      ];
      bool pass = Guard.check(fakeLicense(uses), [
            LicenseUse([LicenseUsecase.custom('test')],
                destinations: ['https://hello.mytiki.com'])
          ]) ==
          null;
      expect(pass, true);
    });

    test('invalid destination - False', () async {
      List<LicenseUse> uses = [
        LicenseUse([LicenseUsecase.custom('test')],
            destinations: ['\\.mytiki\\.com'])
      ];
      bool pass = Guard.check(fakeLicense(uses), [
            LicenseUse([LicenseUsecase.custom('test')],
                destinations: ['blockme'])
          ]) ==
          null;
      expect(pass, false);
    });

    test('multiple valid destinations - True', () async {
      List<LicenseUse> uses = [
        LicenseUse([LicenseUsecase.custom('test')],
            destinations: ['\\.mytiki\\.com', '\\.dummy\\.com'])
      ];
      bool pass = Guard.check(fakeLicense(uses), [
            LicenseUse([
              LicenseUsecase.custom('test')
            ], destinations: [
              'https://hello.mytiki.com',
              'https://test.mytiki.com',
              'https://hello.dummy.com'
            ])
          ]) ==
          null;
      expect(pass, true);
    });

    test('multiple invalid destinations - False', () async {
      List<LicenseUse> uses = [
        LicenseUse([LicenseUsecase.custom('test')],
            destinations: ['\\.mytiki\\.com'])
      ];
      bool pass = Guard.check(fakeLicense(uses), [
            LicenseUse([
              LicenseUsecase.custom('test')
            ], destinations: [
              'https://hello.mytiki.com',
              'https://test.mytiki.com',
              'blockme'
            ])
          ]) ==
          null;
      expect(pass, false);
    });

    test('invalid combo - False', () async {
      List<LicenseUse> uses = [
        LicenseUse([LicenseUsecase.custom('test')],
            destinations: ['\\.mytiki\\.com']),
        LicenseUse([LicenseUsecase.custom('test1')],
            destinations: ['\\.dummy\\.com'])
      ];
      bool pass = Guard.check(fakeLicense(uses), [
            LicenseUse([LicenseUsecase.custom('test')],
                destinations: ['https://hello.dummy.com'])
          ]) ==
          null;
      expect(pass, false);
    });
  });
}
