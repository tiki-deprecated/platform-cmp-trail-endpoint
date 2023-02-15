---
title: Getting Started
excerpt: See just how easy (and fast) it is to add TIKI to your product —drop a user data exchange into your existing app, increasing opt-ins and lowering risk.
category: 637af030c0112e000f59b816
slug: tiki-sdk-dart-getting-started
hidden: false
order: 1
next:
  pages:
    - type: ref
      icon: book
      name: View the entire API
      slug: tiki-sdk-dart-tiki-sdk
      category: SDK [Dart]
---

_Before you get started, for new projects, we recommend one of our platform-specific SDKs. Same features. Much easier to implement._

#### 🤖 Android: [tiki-sdk-android](tiki-sdk-android-getting-started)

#### 🍎 iOS: [tiki-sdk-ios](tiki-sdk-ios-getting-started)

#### 🦋 Flutter: [tiki-sdk-flutter](tiki-sdk-flutter-getting-started)

---
### Installation
```
$ dart pub add tiki_sdk_dart
```
This will add a line like this to your package's pubspec.yaml (and run an implicit dart pub get):
```
dependencies:
  tiki_sdk_dart: ^1.0.0
```
### Usage
#### 1. [Sign up](https://console.mytiki.com) (free) for a TIKI developer account to get an API ID.
#### 2. Initialize the TIKI SDK using [TikiSdkBuilder](tiki-sdk-dart-tiki-sdk-builder)
Configuration parameters:
-  **origin &#8594; String**
Included in the on-chain transaction to denote the application of origination (can be overridden in individual requests). It should follow a reverse-DNS syntax. _i.e. com.mycompany.myproduct_

-  **databaseDir &#8594; String**
Defines where the local data (SQLite used for persistence) will be stored.

-  **publishingId &#8594; String**
A unique identifier for your account. Create, revoke, and cycle Ids _(not a secret but try and treat it with care)_ at [TIKI Console](https://console.mytiki.com).

-  **address &#8594; String**
Set the user address (primarily for restoring the state on launch). If not set, a new key pair and address will be generated for the user.
-  **keyStorage &#8594; [KeyStorage](tiki-sdk-dart-key-storage)**
A platform-specific implementation of the [KeyStorage](tiki-sdk-dart-key-storage) interface. User keys are sensitive and need to be kept encrypted in a secure location.

**Example:**
```
TikiSdk tiki = await (TikiSdkBuilder()
  ..origin('com.mycompany.myproduct')
  ..databaseDir('/')
  ..apiKey('565b3268-cdc0-4e5c-94c8-5d8f53d4577c')
  ..keyStorage(MyKeyStorageImpl()))
  .build();
```
#### 3. Assign ownership
To start using TikiSdk, the assignOwnership method must be utilized to establish ownership of a specific data source. This method generates an Ownership NFT, a unique digital token that identifies the owner of a particular piece of data and its corresponding data type. Additional information, such as a description, can be provided, and an override for the default origin can be specified using the about parameter. The ownershipId identifier returned by the method is crucial for requesting consent from the user to use the data source associated with this ownership.

Parameters:
-  **source &#8594; String**
An identifier in your system corresponding to the raw data. _i.e. a user_id_.
-  **type &#8594; [TikiSdkDataTypeEnum](tiki-sdk-dart-tiki-sdk-data-type-enum)**
The type of data in the source: point, pool, or stream.
-  **contains &#8594; List&lt;String>**
A list of metadata tags describing the represented data.
-  **about &#8594; String?**
An optional description to provide additional context to the transaction. Most typically as human-readable text.
-  **origin &#8594; String?**
An optional override of the default origin set during initialization

Returns:
-  **String**
The unique transaction id represented in a base64 url-safe String.

Example:
```
String ownershipId = tikiSdk.assignOwnership(
  "com.mytiki.example_app",
  TikiSdkDataTypeEnum.data_point,
  ["user_id", "login_timestamp"],
  about: "This data point records when the user logged in",
  origin: "com.mytiki.example_app.login_flow"});
```
#### 4. Modify consent
After establishing ownership of a data source, the `modifyConsent` method can be used to update consent settings for data usage. Consent status is stored in a Consent NFT, and a new NFT is created to modify the user decision. By default, data usage requests are denied unless specified in the destination parameter. If consent is revoked, `TikiSdkDestination.uses` and `TikiSdkDestination.paths` lists will be empty. The Consent NFT can also provide additional information, such as a description or compensation, using optional parameters, and set an expiration date for the consent with the `expiry` parameter. The method returns the latest ConsentModel that represents the NFT.

Parameters:

-  **ownershipId &#8594; String**
The transaction id for the ownership grant (base64 url-safe representation)

-  **destination &#8594; [TikiSdkDestination](tiki-sdk-dart-tiki-sdk-destination)**
A collection of paths and application use cases that consent has been granted (or revoked) for.
-  **about &#8594; String?**
An optional description to provide additional context to the transaction. Most typically as human-readable text.
-  **reward &#8594; String?**
An optional definition of a reward promised to the user in exchange for consent.
-  **expiry &#8594; DateTime?**
The date upon which the consent is no longer valid. If not set, consent is perpetual.

Returns:

-  **[ConsentModel](tiki-sdk-dart-consent-model)**
The modified consent NFT

Example:

```
ConsentModel consent = tikiSdk.modifyConsent(
  <unique ownershipId>, 
  TikiSdkDestination(
	  ["api.mycompany.com/tracklogin"], 
	  uses: ["track login"]),
  about: "Track when the user logged in the app.", 
  reward: "10 points in the loyalty program", 
  expiry: DateTime.now().add(Duration(days:365));
````

#### 5. Apply consent  
The `applyConsent` method verifies a user's consent for a specified data source and destination. If valid consent exists, the method executes a request. If no valid consent exists, the `onBlocked` callback function is called with a message indicating why the request was blocked. 

Parameters:

-  **source &#8594; String**
An identifier in your system corresponding to the raw data. _i.e. a user_id_

-  **destination &#8594; TikiSdkDestination**
The destination(s) and use case(s) for the request.

-  **request &#8594; Function()**
The function to execute if consent granted

-  **onBlocked &#8594; Function(String)?**
An optional function to execute if consent is denied.

-  **origin &#8594; String?**
An optional override of the default origin set during initialization

Returns:

-  **Future&lt;void>**
Example:
```
Function request = () => sendDataToServer();
Function onBlocked = (String reason) => print("blocked: $reason");
tikiSdk.applyConsent(
	"com.mytiki.example_app",
	TikiSdkDestination(
	  ["api.mycompany.com/tracklogin"], 
	  uses: ["track login"]),
	request, 
	onBlocked: onBlocked,
	origin: "com.mytiki.example_app.login_flow");
```