---
title: TikiSdkDestination
excerpt: The destination to which the data is consented to be used.
category: 6379d3b069658a0031973026
slug: tiki-sdk-dart-tiki-sdk-destination
hidden: false
order: 4
---

## Constructors

##### TikiSdkDestination(List&lt;String> paths, {List&lt;String> uses = const []})

Builds a destination with `paths` and `uses`.  
_const_

##### TikiSdkDestination.all()

Builds a destination for all `paths` and `uses`  
_const_

##### TikiSdkDestination.fromMap(Map map)

##### TikiSdkDestination.none()

Builds a destination with no `paths` nor `uses`.  
_const_

## Properties

##### paths &#8594; List&lt;String>

A list of paths, preferably URL without the scheme or
reverse FQDN. Keep list short and use wildcard matching. Prefix with NOT to invert (i.e. NOT mytiki.com/).  
_final_

##### uses &#8594; List&lt;String>

An optional list of application specific uses cases applicable to the given destination. Prefix with NOT to invert (i.e.
NOT ads).  
_final_

## Methods

##### serialize() &#8594; Uint8List

Serializes the destination as a byte array to be used in the blockchain.

##### toJson() &#8594; String

## Static Methods

##### deserialize(Uint8List serialized) &#8594; TikiSdkDestination

Deserializes a byte array into a destination.

##### fromJson(String jsonString) &#8594; TikiSdkDestination

Converts the json representation of the destination into its object.