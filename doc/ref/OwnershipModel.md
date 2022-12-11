---
title: OwnershipModel
excerpt: An Ownership Object. Representative of the NFT created on-chain.
category: 6379d3b069658a0031973026
slug: tiki-sdk-dart-ownership-model
hidden: false
order: 6
---

## Constructors

##### OwnershipModel({Uint8List? transactionId, required String source, required [TikiSdkDataTypeEnum](tiki-sdk-dart-tiki-sdk-data-type-enum) type, required String origin, List&lt;String> contains = const [], String? about})

##### OwnershipModel.fromMap(Map&lt;String, dynamic> map)  
Builds a `OwnershipModel` based in a Map. Used mostly for database operations.

## Properties

##### transactionId &#8596; Uint8List?
The transaction id for `this`  
_read / write_

##### source &#8594; String
An identifier in your system corresponding to the raw data.  
_i.e. a user_id_

##### type &#8594; [TikiSdkDataTypeEnum](tiki-sdk-dart-tiki-sdk-data-type-enum)
Point, pool, or stream.  
_read / write_

##### origin &#8594; String?
The origin from which the data was generated.  
_read / write_

##### contains &#8596; List&lt;String>
A list of metadata tags describing the represented data.  
_read / write_

##### about &#8596; String?
An optional description to provide additional context to the transaction. Most typically as human-readable text.  
_read / write_

## Methods

##### serialize() &#8594; Uint8List
Serialize the ownership as a byte array. Used in transaction creation.

## Static Methods

##### deserialize(Uint8List serialized) &#8594; ConsentModel
Deserialize an ownership byte array, creating a new `OwnershipModel`.