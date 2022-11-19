![Image](https://img.shields.io/github/deployments/tiki/tiki-sdk-dart/Production?label=deployment&logo=github)
![Image](https://img.shields.io/github/workflow/status/tiki/tiki-sdk-dart/docs?label=docs&logo=github)
![Image](https://img.shields.io/pub/v/tiki_sdk_dart?logo=dart)
![Image](https://img.shields.io/pub/points/tiki_sdk_dart?logo=dart)
![Image](https://img.shields.io/github/license/tiki/tiki-sdk-dart)

# TIKI SDK —build the new data economy

### [📚 Docs](https://mytiki.com/tiki-sdk-dart/) | [💬 Discord](https://discord.gg/tiki)

The core implementation (**pure dart**) of TIKI's decentralized infrastructure plus abstractions to simplify the tokenization and application of data ownership, consent, and rewards.
For new projects, we recommend one of our platform-specific SDKs. Same features. Much easier to implement.

#### 🤖 Android: [tiki-sdk-android](https://github.com/tiki/tiki-sdk-android)
#### 🍎 iOS: [tiki-sdk-ios](https://github.com/tiki/tiki-sdk-ios)
#### 🦋 Flutter: [tiki-sdk-flutter](https://github.com/tiki/tiki-sdk-flutter)

## Getting Started

### Installation

```
 $ dart pub add tiki_sdk_dart
```
This will add a line like this to your package's pubspec.yaml (and run an implicit dart pub get):
```
dependencies:
  tiki_sdk_dart: ^0.0.9
```

### Usage

#### 1. [Sign up](https://console.mytiki.com) (free) for a 🍍TIKI developer account to get an API ID.

#### 2. Initialize the TIKI SDK using `TikiSdkBuilder`

Configuration parameters:
- `origin: String`  
  Included in the on-chain transaction to denote the application of origination (can be overridden in individual requests). It should follow a reversed FQDN syntax. _i.e. com.mycompany.myproduct_


- `databaseDir: String`  
  Defines where the local data (SQLite used for persistence) will be stored.


- `apiId: String`  
  A unique identifier for your account. Create, revoke, and cycle Ids _(not a secret but try and treat it with care)_ at https://mytiki.com.


- `address: String?`  
  Set the user address (primarily for restoring the state on launch). If not set, a new key pair and address will be generated for the user.


- `keyStorage: KeyStorage`  
  A platform-specific implementation of the `KeyStorage` interface. User keys are sensitive and need to be kept encrypted in a secure location. We recommend:
  - Flutter - [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage)
  - Android - [Keystore](https://developer.android.com/training/articles/keystore.html)
  - iOS - [Keychain](https://developer.apple.com/documentation/security/keychain_services#//apple_ref/doc/uid/TP30000897-CH203-TP1)
  - JS - [IndexedDB](https://developer.mozilla.org/en-US/docs/Web/API/IndexedDB_API)

Example:

```
    TikiSdk tiki = await (TikiSdkBuilder()
          ..origin('com.mycompany.myproduct')
          ..databaseDir('/')
          ..apiKey('565b3268-cdc0-4e5c-94c8-5d8f53d4577c')
          ..keyStorage(MyKeyStorageImpl()))
          .build();
```

#### 3. Assign ownership
Data ownership can be assigned to any data point, pool, or stream, creating an immutable, on-chain record.

Parameters:
- `source: String` - An identifier in your system corresponding to the raw data. _i.e. a user_id_


- `type: TikiSdkDataTypeEnum` - Point, pool, or stream


- `contains: List<String` - A list of metadata tags describing the represented data


- `origin: String?` - An optional override of the default origin set during initialization


- `about: String?` - An optional description to provide additional context to the transaction. Most typically as human-readable text.

Returns:
- `transactionId: String` - The unique transaction id (use to recall the transaction record at any time)

Example:

```
String oid = await tiki.assignOwnership('12345', TikiSdkDataTypeEnum.point, ['email_address']);
```

#### 4. Modify consent
Consent is given (or revoked) for data ownership records. Consent defines "who" the data owner has given utilization rights.

Parameters:
- `ownershipId: String` - The transaction id for the ownership grant


- `destination: TikiSdkDestination` - A collection of paths and application use cases that consent has been granted (or revoked) for.


- `expiry: DateTime?` - The date upon which the consent is no longer valid. If not set, consent is perpetual.


- `reward: String?` - An optional definition of a reward promised to the user in exchange for consent.


- `about: String?` - An optional description to provide additional context to the transaction. Most typically as human-readable text.

Returns:
- `transactionId: String` - the unique transaction id (use to recall the transaction record at any time)

Example:
```
String cid = await tiki.modifyConsent(oid, const TikiSdkDestination.all());
```

#### 5. Apply consent
Apply consent to a data transaction. If consent is granted for the `source` and `destination` and has not expired, the request is executed.

Parameters:
- `source: String` - An identifier in your system corresponding to the raw data. _i.e. a user_id_


- `destination: TikiSdkDestination` - The destination(s) and use case(s) for the request.


- `request: Function` - The function to execute if consent granted


- `onBlocked: Function(String)?` - An optional function to execute if consent is denied.


- `origin: String?` - An optional override of the default origin set during initialization

Example:
```
await tiki.applyConsent('12345', const TikiSdkDestination.all(),
          () => print('Consent Approved. Send data to backend.')
```

##  Basic Architecture

We leverage a novel blockchain-inspired data structure to create immutable, decentralized records of data ownership, consent grants, and rewards.

Unlike typical shared-state ⛓️ blockchains, TIKI operates on no consensus model, pushing scope responsibility to the application layer —kind of like shared cloud storage.

The structure enables tokenization at the edge (no cost, high speed). Read more about it [here](https://github.com/tiki/.github/blob/main/profile/WHITEPAPER-2CHAINZ.md).

✨ Highlights:
- No compute costs
- No backend changes
- Data remains private (never sent to a TIKI server)
- No P2P networking
- Fast AF and horizontally scalable (benchmarked on iPhones at 20,000 TPS)
- Immutable backup for 10+ yrs. via TIKI's L0 Storage service.

#### Node

Manages transaction creation, block packaging, backups, chain validation, and key management. Basically, all the blockchain stuff.

#### Ownership and Consent

A cache layer (SQLite) on top of the chain data structure. Simplifies the execution of actions such as tokenization, consent modification, and consent application.

#### SStorage (L0 Storage)

The client-side interface for TIKI's L0 Storage service. A free, long-term (10 yrs.), immutable backup service. Learn more about it [here](https://github.com/tiki/l0-storage).

## Why Dart?
🎯 Dart compiles to both machine code for native mobile/desktop apps and JS for web.

The vast majority of data origination and person-to-business exchange happens at the edge (web/mobile). Plus, edge execution can offer significant privacy and performance advantages.
