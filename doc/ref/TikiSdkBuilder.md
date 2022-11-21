---
title: TikiSdkBuilder
excerpt: The Builder class for the [TikiSdk](tiki-sdk-dart-tiki-sdk) object
category: 6379d3b069658a0031973026
slug: tiki-sdk-dart-tiki-sdk-builder
hidden: false
order: 2
---

## Constructors

##### TikiSdkBuilder ()

## Methods

##### origin(String origin) &#8594; void
Included in the on-chain transaction to denote the application of origination (can be overridden in individual requests). It should follow a reversed FQDN syntax.  
_i.e. com.mycompany.myproduct_

##### databaseDir(String databaseDir) &#8594; void
Defines where the local data (SQLite used for persistence) will be stored.

##### apiId(String? apiId) &#8594; void
A unique identifier for your account. Create, revoke, and cycle Ids _(not a secret but try and treat it with care)_ at [console.mytiki.com](https://console.mytiki.com).

##### address(String? address) &#8594; void
Set the user `address` (primarily for restoring the state on launch). If not set, a new key pair and address will be generated for the user.

##### keyStorage([KeyStorage](tiki-sdk-dart-key-storage) keyStorage) &#8594; void
A platform-specific implementation of the [KeyStorage](storage) interface. User keys are sensitive and need to be kept encrypted in a secure location.

##### build() &#8594; Future&lt;[TikiSdk](tiki-sdk-dart-tiki-sdk)>
Configures required services, building, and returning the [TikiSdk]() object.

Example:
```
    TikiSdk tiki = await (TikiSdkBuilder()
          ..origin('com.mycompany.myproduct')
          ..databaseDir('/')
          ..apiKey('565b3268-cdc0-4e5c-94c8-5d8f53d4577c')
          ..keyStorage(MyKeyStorageImpl()))
          .build();
```

















