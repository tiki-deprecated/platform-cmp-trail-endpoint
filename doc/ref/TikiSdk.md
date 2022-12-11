---
title: TikiSdk
excerpt: The primary object for interacting with the TIKI infrastructure. Use `TikiSdk` to assign ownership, modify, and apply consent.
category: 6379d3b069658a0031973026
slug: tiki-sdk-dart-tiki-sdk
hidden: false
order: 1
---

## Constructors

##### TikiSdk (OwnershipService os, ConsentService cs, NodeService ns)  
Do not build directly, use [TikiSdkBuilder](tiki-sdk-dart-tiki-sdk-builder).

## Properties

##### address &#8594; String
The wallet `address` in use. Set (or generated) during construction.  
_read-only_

## Methods

##### assignOwnership(String source, [TikiSdkDataTypeEnum](tiki-sdk-dart-tiki-sdk-data-type-enum) type, List&lt;String> contains, {String? about, String? origin}) &#8594; Future&lt;String>  
Data ownership can be assigned to any data point, pool, or stream, creating an immutable, on-chain record.  

Parameters:
- **source &#8594; String**  
An identifier in your system corresponding to the raw data.  
_i.e. a user_id_


- **type &#8594; [TikiSdkDataTypeEnum](tiki-sdk-dart-tiki-sdk-data-type-enum)**  
Point, pool, or stream


- **contains &#8594; List&lt;String>**  
A list of metadata tags describing the represented data


- **origin &#8594; String?**  
An optional override of the default origin set during initialization


- **about &#8594; String?**  
An optional description to provide additional context to the transaction. Most typically as human-readable text.

Returns:
- **String**  
The unique transaction id (use to recall the transaction record at any time)

Example:

```
String oid = await tiki.assignOwnership('12345', TikiSdkDataTypeEnum.point, ['email_address']);
```

&nbsp;

##### modifyConsent(String ownershipId, [TikiSdkDestination](tiki-sdk-dart-tiki-sdk-destination) destination, {String? about, String? reward, DateTime? expiry}) &#8594; Future&lt;[ConsentModel](tiki-sdk-dart-consent-model)>  
Consent is given (or revoked) for data ownership records. Consent defines "who" the data owner has given utilization rights.

Parameters:
- **ownershipId &#8594; String**  
The transaction id for the ownership grant


- **destination &#8594; [TikiSdkDestination](tiki-sdk-dart-tiki-sdk-destination)**  
A collection of paths and application use cases that consent has been granted (or revoked) for.


- **expiry &#8594; DateTime?**  
The date upon which the consent is no longer valid. If not set, consent is perpetual.


- **reward &#8594; String?**  
An optional definition of a reward promised to the user in exchange for consent.


- **about &#8594; String?**  
An optional description to provide additional context to the transaction. Most typically as human-readable text.

Returns:
- **[ConsentModel](tiki-sdk-dart-consent-model)**  
the modified `ConsentModel`

Example:
```
ConsentModel consent = await tiki.modifyConsent(oid, const TikiSdkDestination.all());
```

&nbsp;

##### getOwnership(String source, {String? origin}) &#8594; [OwnerhsipModel](tiki-sdk-dart-ownership-model)?
Get the `OwnershipModel` for a `source` and `origin`. If `origin` is unset, the default set during construction is used.

Parameters:
- **source &#8594; String**  
  An identifier in your system corresponding to the raw data.  
  _i.e. a user_id_


- **origin &#8594; String?**  
  An optional override of the default origin set during initialization

Returns:
- **[OwnershipModel](tiki-sdk-dart-consent-model)**  
  the assigned `OwnerhsipModel`

Example:
```
OwnershipModel? consent = await tiki.getOwnership('12345');
```

&nbsp;

##### getConsent(String source, {String? origin}) &#8594; [ConsentModel](tiki-sdk-dart-consent-model)?  
Get the latest `ConsentModel` for a `source` and `origin`. If `origin` is unset, the default set during construction is used.

Parameters:
- **source &#8594; String**  
  An identifier in your system corresponding to the raw data.  
  _i.e. a user_id_


- **origin &#8594; String?**  
An optional override of the default origin set during initialization

Returns:
- **[ConsentModel](tiki-sdk-dart-consent-model)**  
  the latest `ConsentModel` 

Example:
```
ConsentModel? consent = await tiki.getConsent('12345');
```

&nbsp;

##### applyConsent(String source, [TikiSdkDestination](tiki-sdk-dart-tiki-sdk-destination) destination, Function() request, {void Function(String)? onBlocked, String? origin}) &#8594; Future&lt;void>  
Apply consent to a data transaction. If consent is granted for the `source` and `destination` and has not expired, the request is executed.

Parameters:
- **source &#8594; String**  
An identifier in your system corresponding to the raw data.  
_i.e. a user_id_


- **destination &#8594; [TikiSdkDestination](tiki-sdk-dart-tiki-sdk-destination)**  
The destination(s) and use case(s) for the request.


- **request &#8594; Function()**  
The function to execute if consent granted


- **onBlocked &#8594; Function(String)?**  
An optional function to execute if consent is denied.


- **origin &#8594; String?**  
An optional override of the default origin set during initialization

Returns:  
- **Future&lt;void>**

Example:
```
await tiki.applyConsent('12345', const TikiSdkDestination.all(), () => print('Consent Approved. Send data to backend.')
```