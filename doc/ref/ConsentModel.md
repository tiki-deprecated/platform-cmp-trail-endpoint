---
title: ConsentModel
excerpt: A Consent Object. Representative of the NFT created on-chain. Requires a corresponding Data Ownership NFT (see [TikiSdk](tiki-sdk-dart-tiki-sdk)).
category: 6379d3b069658a0031973026
slug: tiki-sdk-dart-consent-model
hidden: false
order: 6
---

## Constructors

##### ConsentModel(Uint8List ownershipId, [TikiSdkDestination](tiki-sdk-dart-tiki-sdk-destination) destination, {String? about, String? reward, DateTime? expiry})  
Builds a ConsentModel for the data identified by `ownershipId`.

##### ConsentModel.fromMap(Map&lt;String, dynamic> map)  
Builds a ConsentModel based in a Map. Used mostly for database operations.

## Properties

##### about &#8596; String?
An optional description to provide additional context to the transaction. Most typically as human-readable text.
_read / write_

##### destination &#8596; [TikiSdkDestination](tiki-sdk-dart-tiki-sdk-destination)
The destination describing the allowed/disallowed paths and use cases for the consent.  
_read / write_

##### expiry &#8596; DateTime?
The date the consent is valid until. Do no set (`Null`) for perpetual consent.
_read / write_

##### ownershipId &#8596; Uint8List
The data ownership transaction ID corresponding to the data source consent applies to.  
_read / write_

##### reward &#8596; String?
An optional description of the reward owed to user in exchange for consent.
_read / write_

##### transactionId &#8596; Uint8List?
The transaction id for `this`  
_read / write_

## Methods

##### serialize() &#8594; Uint8List
Serialize the consent as a byte array. Used in transaction creation.

## Static Methods

##### deserialize(Uint8List serialized) &#8594; ConsentModel
Deserialize a consent byte array, creating a new `ConsentModel`.