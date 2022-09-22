import 'package:test/test.dart';
import 'package:tiki_sdk_dart/tiki_sdk.dart';

void main() {
  String defaultOrigin = "default";

  String apiKey = 'testKey';

  List<String> ids = ["user123", "user456"];

  test('TikiSdk init', () async {
    TikiSdk tikiSdk = TikiSdk(defaultOrigin, apiKey: apiKey);
    tikiSdk.init(ids: ids);
    expect(tikiSdk.ids, ids);
    expect(tikiSdk.origin, defaultOrigin);
  });

  test('TikiSdk add/remove ids', () async {
    TikiSdk tikiSdk = TikiSdk(defaultOrigin, apiKey: apiKey);
    await tikiSdk.init(ids: ids);
    tikiSdk.addId("user789");
    expect(tikiSdk.ids.length, 3);
    tikiSdk.removeId("user123");
    expect(tikiSdk.ids.length, 2);
  });

  test('TikiSdk grantOwnership', () async {
    TikiSdk tikiSdk = TikiSdk(defaultOrigin, apiKey: apiKey);
    await tikiSdk.init(ids: ids);
    expect(
        () =>
            tikiSdk.grantOwnership('EMAIL', [TikiSdkDataTypeEnum.emailAddress]),
        throwsUnimplementedError);
  });

  test('TikiSdk modifyConsent', () async {
    TikiSdk tikiSdk = TikiSdk(defaultOrigin, apiKey: apiKey);
    await tikiSdk.init(ids: ids);
    expect(() => tikiSdk.modifyConsent('EMAIL', []), throwsUnimplementedError);
  });

  test('TikiSdk applyConsent', () async {
    TikiSdk tikiSdk = TikiSdk(defaultOrigin, apiKey: apiKey);
    await tikiSdk.init(ids: ids);
    expect(
        () => tikiSdk.applyConsent('EMAIL', TikiSdkDestination([]), () => null),
        throwsUnimplementedError);
  });
}
