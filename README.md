![Image](https://user-images.githubusercontent.com/3769672/184012083-4c3598d2-f81c-43f4-85cb-54fd731aeb1b.png)

![Image](https://img.shields.io/github/deployments/tiki/tiki-sdk-dart/Production?label=deployment&logo=github)
![Image](https://img.shields.io/github/workflow/status/tiki/tiki-sdk-dart/docs?label=docs&logo=github)
![Image](https://img.shields.io/pub/v/tiki_sdk_dart?logo=dart)
![Image](https://img.shields.io/pub/points/tiki_sdk_dart?logo=dart)
![Image](https://img.shields.io/github/license/tiki/tiki-sdk-dart)

## What is TIKI SDK?
TIKI is a decentralized data exchange (DEX) built on ⛓ blockchain tech, enabling direct people-to-business data trade —meeting privacy requirements while maximizing the flow of data.

Our SDK enables business to seamlessly implement it into their tech projects. No significant compute, network, or storage overhead. No change to existing backend systems required. Anonymous to TIKI.

This is the core implementation of the SDK, including blockchain (assembler, validator, wallet, etc.), ownership minting, and consent handling.  

We recommend to use this SDK just for pure **Dart** implementations. For other platforms, use one of the following:

- ### Android 
  [tiki-sdk-android](https://github.com/tiki/tiki-sdk-android) - Dart SDK wrapped in Flutter Platform Channels and compiled to machine code, combined with platform-specific storage and a native Kotlin API. Use as a maven dependency.

- ### iOS
  [tiki-sdk-ios](https://github.com/tiki/tiki-sdk-ios) - Dart SDK wrapped in Flutter Platform Channels and compiled to machine code, combined with platform-specific storage and a native Swift API. Use in your project as a Swift Package.

- ### Flutter
  [tiki-sdk-flutter](https://github.com/tiki/tiki-sdk-flutter) - Combines Dart SDK with Flutter-specific storage libs. Just add the package to your pubspec.

## Getting started

No expertise in data, privacy, or crypto needed.
(But if you have some, everything is open source. Throw us a PR.)


### Dart

```
 $ dart pub add tiki_sdk_dart
```
This will add a line like this to your package's pubspec.yaml (and run an implicit dart pub get):
```
dependencies:
  tiki_sdk_dart: ^0.0.7
```


## How to use

### 1 - Initialize the builder

```
  TikiSdkBuilder builder = TikiSdkBuilder();
```

### 2 - Set the default Origin

The default origin is the one that will be used as origin for all ownership assignments that doesn't define different origins. It should follow a reversed FQDN syntax. _i.e. com.mycompany.myproduct_

```
builder.origin('com.mycompany.myproduct');
```

### 3 - Set the Database Directory

TIKI SDK uses SQLite for local database caching. This directory defines where the database files will be stored.

```
builder.databaseDir('path/to/database')
```

### 4 - Set the storage for user`s private key
The user private key is sensitive information and should be kept in a secure and encrypted key-value storage. It should use an implementation of the `KeyStorage` interface,
```
builder.keyStorage = InMemKeyStorage();
```

**DO NOT USE InMemKeyStorage in production.**
### 5 - Set the API key for connection with TIKI Cloud
Create your API key in [mytiki.com](mytiki.com)
```
builder.apiKey = "api_key_from_mytiki.com";
```

### 6 - address
Set the user address. If it is not set, a new private key will be created for the user.
```
builder.apiKey = "api_key_from_mytiki.com";
```
### 7 - Build it!
After setting all the properties for the builder, build it to use.
```
TikiSdk sdk = builder.build();
```
