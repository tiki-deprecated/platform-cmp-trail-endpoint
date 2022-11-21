---
title: TikiSdkDataTypeEnum
excerpt: An enumeration of the supported data aggregation types.
category: 6379d3b069658a0031973026
slug: tiki-sdk-dart-tiki-sdk-data-type-enum
hidden: false
order: 5
---

## Constructors

##### TikiSdkDataTypeEnum.fromValue(String value)
Construct a new `TikiSdkDataTypeEnum` from a string value. See Constants below.  
_factory_

## Values

##### point &#8594; const TikiSdkDataTypeEnum
A singular data object/field  
_i.e email address or image_

##### pool &#8594; const TikiSdkDataTypeEnum
An aggregation of multiple data fields and objects connected to a specific identifier.  
_i.e. a user's profile or purchase history_

##### stream &#8594; const TikiSdkDataTypeEnum
An ongoing flow of user data on regular basis.  
_i.e. in-app analytics or location data_

## Properties

##### val &#8594; String

_final_

## Constants

##### values &#8594; const List&lt;TikiSdkDataTypeEnum>
A constant `List` of the values, in order of their declaration: `[point, pool, stream]`









