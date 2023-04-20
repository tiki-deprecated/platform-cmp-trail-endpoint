import 'package:example/in_mem.dart';
import 'package:tiki_sdk_dart/tiki_sdk.dart';
import 'package:uuid/uuid.dart';

void main(List<String> arguments) async {
    TikiSdk tikiSdk = await InMemBuilders.tikiSdk();
    String ptr = const Uuid().v4();
    TitleRecord title =
      await tikiSdk.title(ptr, tags: [TitleTag.emailAddress()]);
    print("Created a Title Record with id ${title.id} for PTR: $ptr");
    LicenseRecord first = await tikiSdk.license(
          ptr,
          [
            LicenseUse([LicenseUsecase.attribution()])
          ],
          'terms');
    print("Created a License Record with id ${first.id} for PTR: $ptr");
}
