---
title: ConsentModel
excerpt: The Consent NFT data structure. It registers the consent from the creator of an Ownership NFT for the use of that data in a specific destination. Optionally the Consent can describe about its usage, a reward that will be given in exchange and an expiry date and time for the consent.
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
Optional description of the consent.  
_read / write_

##### destination &#8596; [TikiSdkDestination](tiki-sdk-dart-tiki-sdk-destination)
The identifier of the paths and use cases for this consent.  
_read / write_

##### expiry &#8596; DateTime?
_read / write_

##### ownershipId &#8596; Uint8List
Transaction ID corresponding to the ownership NFT for the data source.  
_read / write_

##### reward &#8596; String?
Optional reward description the user will receive for this consent.  
_read / write_

##### transactionId &#8596; Uint8List?
The transaction id of this registry.  
_read / write_

## Methods

##### serialize() &#8594; Uint8List
Serializes the contents to be recorded in the blockchain.

## Static Methods

##### deserialize(Uint8List serialized) &#8594; ConsentModel
Deserializes the contents that was loaded from the blockchain.  












