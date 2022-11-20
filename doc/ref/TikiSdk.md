---
title: TikiSdk
excerpt: The TIKI SDK that enables the creation of Ownership and Consent NFTs for data. Use [TikiSdkBuilder](tiki-sdk-dart-tiki-sdk-builder) to build an instance of this.
category: 6379d3b069658a0031973026
slug: tiki-sdk-dart-tiki-sdk
hidden: false
order: 1
---

## Constructors

##### TikiSdk (OwnershipService os, ConsentService cs, NodeService ns)

## Properties

##### address &#8594; String

The blockchain address that is in use by this TikiSdk.   
_read-only_

## Methods

##### assignOwnership(String source, [TikiSdkDataTypeEnum](tiki-sdk-dart-tiki-sdk-data-type-enum) type, List&lt;String> contains, {String? about, String? origin}) &#8594; Future&lt;String>

Assign ownership to a given <code>source</code>.

##### modifyConsent(String ownershipId, [TikiSdkDestination](tiki-sdk-dart-tiki-sdk-destination) destination, {String? about, String? reward, DateTime? expiry}) &#8594; Future&lt;[ConsentModel](tiki-sdk-dart-consent-model)>

Modify consent for an ownership identified by <code>ownershipId</code>.

##### getConsent(String source, {String? origin}) &#8594; [ConsentModel](tiki-sdk-dart-consent-model)?

Gets latest consent given for a <code>source</code> and <code>origin</code>.

##### applyConsent(String source, [TikiSdkDestination](tiki-sdk-dart-tiki-sdk-destination) destination, Function request, {void Function(String)? onBlocked, String? origin}) &#8594; Future&lt;void>

Apply consent for a given <code>source</code> and <code>destination</code>.