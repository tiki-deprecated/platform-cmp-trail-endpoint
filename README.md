![Image](https://img.shields.io/pub/v/tiki_trail?logo=dart)
![Image](https://img.shields.io/pub/points/tiki_trail?logo=dart)<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
[![All Contributors](https://img.shields.io/badge/all_contributors-4-orange.svg)](#contributors-)
<!-- ALL-CONTRIBUTORS-BADGE:END -->

# TIKI Trail

The TIKI trail project is an immutable, distributed, record system for data
transactions.

The design is inspired by traditional asset record systems, like property
titles, birth certificates, etc. Where the asset itself is external to the
record keeping system.

Traditionally these systems were immutable through paper (only 1 original),
using physical signatures and notaries. Newer-age systems often employ
blockchains to create digital immutability, streamlining costs, improving
access, and time-to-finality. For traditional assets, like land, blockchain gas
costs, and write times are more than sufficient.

But! With data as an asset, that doesn't cut it. There's always workarounds.
Though scaling to trillions of records, often warrants a dedicated design. This
is that.

_For example, TIKI trail benchmarked at over 25,000 transactions per second per
device (iPhone 12)._

The TIKI Trail design utilizes two levels of immutability, first at the data
layer and then at the storage layer. Records are created and digitally-signed
locally using a blockchain-inspired data structure. This enables fast writes,
with 0 gas costs, since records are single-party —using zero-party data as a
standard, the owner of the device creating the data is the owner of the data
itself.

The chain of records is then backed up to one or more
hosted [WORM (write-once, read-many)](https://docs.aws.amazon.com/AmazonS3/latest/userguide/object-lock.html)
repositories. The shared repository functions both as
long term storage for device failure recovery, and
as an index, enabling easy integration of records into backend services.

**If you'd like to read more about the design, check
out the original 📄 [WHITEPAPER.md](WHITEPAPER.md)**.

## How to use

For most applications, we do not recommend using this project directly. Instead,
use one of our dedicated native libraries
for [iOS](https://github.com/tiki/tiki-sdk-ios), [Android](https://github.com/tiki/tiki-sdk-android), [Flutter](https://github.com/tiki/tiki-sdk-flutter),
and [Javascript](https://github.com/tiki/tiki-sdk-js).

**Get familiar with our platform-wide 📚 [docs](https://mytiki.com/docs), or jump
right into the
📘 [API reference](https://pub.dev/documentation/tiki_trail/latest/).**

### Requirements

- A Publishing ID. Get one for free
  at [console.mytiki.com](https://console.mytiki.com).
- A platform-specific secure [key_storage](lib/node/key/key_storage.dart)
  implementation.
- A platform-specific implementation
  of [CommonDatabase](https://pub.dev/documentation/sqlite3/latest/sqlite3.wasm/CommonDatabase-class.html).

### Record Types

While technically this library can be used to create records of any type. We've
simplified and abstracted the API. By all means, feel free to fork and create
your own type(s).

- [TitleRecord](lib/title_record.dart) - describe a data asset and MUST contain
  a Pointer Record to the raw data (often stored in your system).
- [LicenseRecord](lib/license_record.dart) - describe the terms around how a
  data asset may be used and always contain a reference to a corresponding
  TitleRecord.
- [PayableRecord](lib/payable_record.dart) - describe a payment issued or owed
  in accordance with terms of a LicenseRecord.
- [ReceiptRecord](lib/receipt_record.dart) - describe a payment or
  partial-payment in accordance with a PayableRecord.

### Example

[example.dart](example/lib/example.dart)

```
InMemKeyStorage keyStorage = InMemKeyStorage();
CommonDatabase database = sqlite3.openInMemory();

String id = Uuid().v4();
String ptr = const Uuid().v4();

TikiTrail.withId(id, keyStorage);
TikiTrail tiki = await TikiTrail.init('PUBLISHING_ID','com.mytiki.tiki_trail.example', keyStorage, id, database);

TitleRecord title = await tiki.title.create(ptr, tags: [TitleTag.userId()]);
print("Title Record created with id ${title.id} for ptr: $ptr");

LicenseRecord license = await tiki.license.create(title, [LicenseUse([LicenseUsecase.attribution()])],'terms');
print("License Record created with id ${license.id} for title: ${license.title.id}");

tiki.guard(ptr, [LicenseUsecase.attribution()], onPass: () => print("There is a valid license for usecase attribution."));

tiki.guard(ptr, [LicenseUsecase.support()], onFail: (cause) => print("There is not a valid license for usecase support. Cause: $cause"));
```

### Backend Services

The TIKI Trail project interacts with the following backend services:

- [Storage](https://github.com/tiki/l0-storage) - Writing backups to the shared
  WORM repository.
- [Index](https://github.com/tiki/l0-index) - Search and fetch records using
  metadata.
- [Registry](https://github.com/tiki/l0-registry) - Sync user records across
  multiple devices.

## Contributing

The more, the merrier. Just open an issue or fork the project and create a PR.
That's it to make the fancy table 👀.

Please follow
the [Code of Conduct](https://github.com/tiki/.github/blob/main/CODE_OF_CONDUCT.md).

### Contributors

Thanks goes to these wonderful
people ([emoji key](https://allcontributors.org/docs/en/emoji-key)):

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tbody>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://mytiki.com"><img src="https://avatars.githubusercontent.com/u/3769672?v=4?s=100" width="100px;" alt="Mike Audi"/><br /><sub><b>Mike Audi</b></sub></a><br /><a href="https://github.com/tiki/core/commits?author=mike-audi" title="Code">💻</a> <a href="https://github.com/tiki/core/pulls?q=is%3Apr+reviewed-by%3Amike-audi" title="Reviewed Pull Requests">👀</a> <a href="https://github.com/tiki/core/commits?author=mike-audi" title="Documentation">📖</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://www.linkedin.com/in/ricardolg/"><img src="https://avatars.githubusercontent.com/u/8357343?v=4?s=100" width="100px;" alt="Ricardo Gonçalves"/><br /><sub><b>Ricardo Gonçalves</b></sub></a><br /><a href="https://github.com/tiki/core/commits?author=ricardobrg" title="Code">💻</a> <a href="https://github.com/tiki/core/pulls?q=is%3Apr+reviewed-by%3Aricardobrg" title="Reviewed Pull Requests">👀</a> <a href="https://github.com/tiki/core/commits?author=ricardobrg" title="Documentation">📖</a></td>
	  <td align="center" valign="top" width="14.28%"><a href="https://civichacker.com"><img src="https://avatars.githubusercontent.com/u/316840?v=4?s=100" width="100px;" alt="Jurnell Cockhren"/><br /><sub><b>Jurnell Cockhren</b></sub></a><br /><a href="https://github.com/tiki/core/commits?author=jcockhren" title="Code">💻</a></td>
	  <td align="center" valign="top" width="14.28%"><a href="https://harshit933.github.io"><img src="https://avatars.githubusercontent.com/u/90508384?v=4?s=100" width="100px;" alt="Harshit"/><br /><sub><b>Harshit</b></sub></a><br /><a href="https://github.com/tiki/core/commits?author=Harshit933" title="Tests">⚠️</a></td>	
	</tr>
  </tbody>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

This project follows
the [all-contributors](https://github.com/all-contributors/all-contributors)
specification. Contributions of any kind welcome!
