---
title: TikiSdkDestination
excerpt: Defines destinations and use cases (optional) allowed or disallowed. Serializable for inclusion in transactions.
category: 6379d3b069658a0031973026
slug: tiki-sdk-dart-tiki-sdk-destination
hidden: false
order: 4
---
The destination where data can be used with its corresponding usage consent.

It has two properties, `paths` and `uses`, which define the paths where the data can be used and the use cases of the data. These properties are for internal use of the implementer and can be defined with any appropriate string.

For more information about data usage for the end user, the `about` property
in `ConsentModel` and `OwnershipModel` should be used.

To revoke all destinations, use `TikiSdkDestination.none()`.
To allow any destination, use `TikiSdkDestionation.all()`.

## Constructors
##### TikiSdkDestination(List&lt;String> paths, {List&lt;String> uses = const ["*"]})
Creates a new destination from a list of `paths` and optionally `uses`. Default to all `uses`.
_const_

Example 1: destination with URL and "send user data" use.
```
TikiSdkDestination destination = TikiSdkDestination(
  ["api.mycompany.com/v1/user"], uses: ["send user data"]
);
```

Example 2: destination with reverse-DNS and all uses
```
TikiSdkDestination destination = TikiSdkDestination(
  ["com.mycompany.api"]
);
```
Example 3: destination with wildcard URL and NOT keyword in paths.
```
TikiSdkDestination destination = TikiSdkDestination(
	["api.mycompany.com/v1/user/*, 
	NOT api.mycompany.com/v1/user/private]
);
```
##### TikiSdkDestination.all()
Create a destination encompassing all possible `paths` and `uses`
_const_

##### TikiSdkDestination.none()
Create a destination without any `paths` or `uses`
_const_

## Properties

##### paths &#8594; List&lt;String>
A list of paths, preferably URL without the scheme or reverse-DNS. Keep list short and use wildcard () matching. Prefix with NOT to invert.
_i.e. NOT mytiki.com/.
_final_

##### uses &#8594; List&lt;String>
List of optional application-specific use cases applicable to the given destination.
Use the prefix "NOT" to invert a use case. For example, "NOT ads" means that the data should not be used for ads.
_i.e. NOT ads_
_final_

## Methods
##### serialize() &#8594; Uint8List
Serialize the destination as a byte array. Used in transaction creation.
##### toJson() &#8594; String
Serialize the destination as a human-readable JSON string.
##### toMap() &#8594; Map<String, List<String>> 
Creates the Map<String,  List<String> representation of the TikiSdkDestination.
Sample Map:

```
<String, List<String> {
  "paths" : ["path_to_use", "NOT path_to_block"],
  "uses" : ["use case", "NOT not allowed use case"]
}
```

## Static Methods
##### deserialize(Uint8List serialized) &#8594; TikiSdkDestination
Deserialize a destination byte array, creating a new `TikiSdkDestination`.

##### fromJson(String jsonString) &#8594; TikiSdkDestination
Converts the JSON representation of the destination into a TikiSdkDestination.
This function converts a JSON string into a TikiSdkDestination object.
The JSON string must follow the pattern of the default main constructor,
with paths being a required field. If paths is not present, a `TypeError` will be thrown.
The method builds a Map from the JSON string and then calls `TikiSdkDestination.fromMap` to create the `TikiSdkDestination` object.