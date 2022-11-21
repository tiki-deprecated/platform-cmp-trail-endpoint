---
title: TikiSdkDestination
excerpt: Defines destinations and use cases (optional) allowed or disallowed. Serializable for inclusion in transactions.
category: 6379d3b069658a0031973026
slug: tiki-sdk-dart-tiki-sdk-destination
hidden: false
order: 4
---

## Constructors

##### TikiSdkDestination(List&lt;String> paths, {List&lt;String> uses = const []})
Creates a new destination from a list of `paths` and optionally `uses`.  
_const_

##### TikiSdkDestination.all()
Create a destination encompassing all possible `paths` and `uses`  
_const_

##### TikiSdkDestination.none()
Create a destination without any `paths` or `uses`  
_const_

## Properties

##### paths &#8594; List&lt;String>
A list of paths, preferably URLs (without the scheme) or reverse FQDN. 
Keep list short and use wildcard matching. Prefix with NOT to invert.  
_i.e. NOT mytiki.com/.  
_final_

##### uses &#8594; List&lt;String>
An optional list of application specific uses cases applicable to the given destination. Prefix with NOT to invert.  
_i.e. NOT ads_  
_final_

## Methods

##### serialize() &#8594; Uint8List
Serialize the destination as a byte array. Used in transaction creation.

##### toJson() &#8594; String
Serialize the destination as a human-readable JSON string.  

## Static Methods

##### deserialize(Uint8List serialized) &#8594; TikiSdkDestination
Deserialize a destination byte array, creating a new `TikiSdkDestination`.

##### fromJson(String jsonString) &#8594; TikiSdkDestination
Deserialize a destination JSON string, creating a new `TikiSdkDestination`.