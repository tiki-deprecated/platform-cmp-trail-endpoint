<img width="76" alt="image" src="https://user-images.githubusercontent.com/3769672/184012083-4c3598d2-f81c-43f4-85cb-54fd731aeb1b.png">

## Market Requirements
**Pain**  
The user data (data created by people, about people, and their actions) landscape has changed —we’ll spare the history on how we got here. The fact of the matter is people are upset and demanding more transparency, control, and compensation for their [data](https://www.cisco.com/c/dam/en_us/about/doing_business/trust-center/docs/cisco-consumer-privacy-infographic-2020.pdf) . In addition to government [regulation](https://oag.ca.gov/privacy/ccpa), it’s led to sweeping changes in privacy policies from consumer platforms like [Apple](https://markets.businessinsider.com/news/stocks/facebook-meta-stock-apple-idfa-ios-privacy-change-social-media-2022-2) and [Google](https://www.cnbc.com/2022/02/16/google-plans-android-privacy-change-similar-to-apples.html).

The result is two macro business trends. First, companies deeply reliant on user data are reeling, struggling to keep up with a shifting landscape. Risk, brand equity, and compliance costs now outweigh the value with more and more businesses opting to collect and use less [data](https://www.adexchanger.com/ad-exchange-news/why-liveramp-quietly-sold-its-location-data-business-last-year/). Leading to widening gap, less competition, and ultimately worse products and services for consumers. Second, a new data economy is emerging on the back on user data ownership. A wave of new product and services powered by user opt-in is leading to new [circular economies](https://techcrunch.com/2022/06/08/multicoin-capital-leads-60m-investment-in-delphia-to-give-retail-investors-edge-against-hedge-funds/) , [data licensing](https://datacy.com) , [data rewards](https://www.fetchrewards.com) , subscription discounts, walled gardens and more. 

Yet, there remains a sizeable gap in the technology/infrastructure required to keep-up or better yet participate in the user data revolution. Only tech companies with deep talent in data and fintech have been able to pull it off. Companies need tools and services to build the new data economy. In return users get what they’ve been clamoring for, more control, compensation, and transparency with little-no-friction

**Solution**  
Software (SaaS), infrastructure (IaaS), and platform (PaaS) services to enable businesses to participate in new data economy. With TIKI companies can quickly add user-centric data features to their existing applications and services —at at fraction of the cost of building in-house. 

There are 4 core elements to the new data economy: ownership, consent, exchange, and enrichment. Ownership is the assignment and tracking which users own which data whether it be at the point, stream, pool or other level. Consent defines the rules of engagement for owned data. Exchange is the act of providing data (or access to data) for value, most commonly money or in-kind services. 
It starts with user data ownership followed by consent. With data ownership and consent, users gain transparency and control —optionally, companies can reward users for giving consent, aka compensation. 

Companies will interact with TIKI’s data ownership infrastructure and consent platform using SDKs to give users, directly in their own applications, ownership, and consent. Records are immutable creating a definitive record for compliance and risk management. Laying the groundwork for the new data economy. In under an hour, any company regardless of its size should be able to add user data ownership & consent to existing systems.  

**Customer(s)**  
- Companies that rely heavily on user data and concerned about blow-back and legal ramifications. They likely already have a data privacy officers or compliance team with expensive consent mechanisms in-place
- Consumer brands that emphasize user-focus and ethics. Likely with an ESG initiative. User data ownership becomes a competitive differentiator. 
- Tech companies that provide martech, adtech, data, and compliance software to businesses. New features create competitive differentiation and open new revenue streams.
- New data economy companies. Often tech startups but not necessarily as existing businesses seize the opportunity.  

**Deliverable(s)**  
- Version 1.0 of the user data ownership infrastructure and consent platform with a mobile SDK ready for deployment —includes documentation, demo application(s), and whitepaper(s).

**Opportunity**  
Tens of millions of users and trillions of user owned data points.  

- [79%](https://www.statista.com/statistics/1172965/firms-collecting-personal-data/) of US companies collect user data 
- Over 1 million apps use [AdMob’s](https://admob.google.com/home/) mobile advertising SDK 
- Over [26 million](https://www.markinblog.com/how-many-ecommerce-sites/) ecommerce sites 
- [LiveRamp](https://enlyft.com/tech/products/liveramp) has ~50,000 customers, [HubSpot](https://www.hubspot.com/customer-spotlight) and [Salesforce](https://isdicrm.com/why-is-salesforce-the-worlds-number-one-crm/) both have ~150,000
  
## Product Requirements
**Objective**  
The core objective of the SDK is to make it extremely easy for application creators to handle consent from users for the use of their data. Developers simply attach the SDK at either end of their data stream or pool to ensure collected user data is safely and ethically sourced. Users receive transparency and control over their data. 

Immediate use cases include companies that want to de-risk existing data sourcing by implementing user consent and companies that want to add new revenue models based on data (i.e., giving their users rewards for sharing their data).

While the core objective detailed above could be implemented in a non-decentralized manner, with private records of data ownership and user consent, a public, decentralized, and immutable ledger creates true user ownership and verifiable trust. Data access is safest for application creators with a public record of ownership and consent. Implementing a public record works towards the ultimate vision of widespread adoption of user data ownership.  

**Features**  
The SDK must provide three fundamental features. Application creators can implement many exciting systems based on the core features.

1.	Application creators must be able to assign data ownership to users. 

For most use cases, the ownership should be over an entire data stream or pool (i.e., all behavioral data or purchase history) instead of ownership over individual data points. Once the user has been given ownership over their data, they can manage consent (i.e., whether that data can be sent over that stream and to which destinations).

*Example: An app can use the SDK to attach user ownership to the product analytics data stream*

2.	Application creators must be able to give users the ability to manage their data consent.

Application creators should be able to do this when ownership is assigned. The SDK must make it possible for users to manage consent based on data type, destination, and use case.

*Example: An app user can revoke consent for location data used for in-app advertising*

3.	Application creators must be able to check for user consent when sending or receiving data.

The SDK must be runnable both client-side and server-side. Clients (sources) must be able to check consent to determine whether they should send data in the first place. Server-side applications (sinks) may want to check consent to ensure they can use the data they are accessing for their specific use case.

*Example: An app trying to send data over a stream without consent is blocked*

Using these three features in tandem, application creators can easily and securely receive user consent and attach it to their data streams —users can robustly manage consent. These core features allow for additional functionality like compensation for data, granular consent management, and transferring data consent settings across applications.

**User flow and design**  
The most basic usage scenario between an application and a backend server both implementing the SDK would look like this:

 <img width="468" alt="image" src="https://user-images.githubusercontent.com/3769672/184014306-db745d66-c313-42df-a2ef-4fdd573dad50.png">

Application creators can add the SDK to their application and route any data write/read requests thru it. Requests are validated in real-time against locally cached consent, allowing approved requests to continue. Optionally, if the user has not yet consented, they may be redirected to a consent flow.  

Because a public record of data ownership and consent exists, the system is easily expandable to many nodes, without the need for fancy security measures/each node having API keys of any sort —enabling systems with many data stores and third parties to be easily implemented. Any node can use the SDK for incoming or outgoing data streams to ensure consent. 

A more in-depth outline is shown below. Here, we show an example application using the SDK to check for data ownership and consent. Based on the consent settings specified by the user and checked through the SDK, the application sends user data to the allowed destinations.

 <img width="468" alt="image" src="https://user-images.githubusercontent.com/3769672/184014322-4e6c2386-4cf6-41dc-8c8f-95a625e58559.png">

**Timeline**  
- The first SDK release is planned for the end of August ’22. Initial functionality will include on-chain ownership and consent management.

## Technical Specifications
**Overview**  
The SDK will be available for mobile (iOS/Android) and web client applications using [Flutter](https://docs.flutter.dev/development/add-to-app/) and [Flutter Web](https://docs.flutter.dev/get-started/web). Ownership and consent will be recorded on-chain using an L1 implementation as described in [2 Chainz: All the blockchains](https://github.com/tiki/.github/blob/main/profile/WHITEPAPER-2CHAINZ.md) . Blockchain operations will be abstracted by the SDK to provide a simplified API interface. The SDK will offer 3 distinct features.  
1.	User ownership grant over a customer managed data source (stream, pool, point, etc.).
2.	User consent management corresponding to an owned data source (approve/deny).
3.	A consent guard to allow/disallow requests based on user consent against owned data sources.

**Implementation**  
The SDK will be implemented as single library (tiki-sdk-dart) in Dart using Flutter (or Flutter Web) for platform dependent functionality. Local persistence will use SQLite, with platform specific encrypted key storage (iOS: Keychain, Android: AES + RSA Keystore, Web: WebCrypto + IndexedDB). Immutable backups will be hosted by Wasabi using [Object Lock](https://wasabi.com/s3-object-lock-faq/).  

Ownership requires data sources be represented by customer specific identifiers with metadata describing the source type and data. Ownership is granted thru NFT minting on-chain.

Consent is applied to a data source by referencing the customer specific identifier —ownership must exist before consent can be recorded. Consent destination is a wildcard path (URI) with optional use cases and recorded rewards. All consent is deny-by-default, minted on-chain, with the latest record corresponding to the data source ownership defining the current rules-of-engagement. 

The SDK will utilize a [vertical slice](https://jimmybogard.com/vertical-slice-architecture/) pattern based on the original codebases of [wallet](https://github.com/tiki/wallet), [localchain](https://github.com/tiki/localchain) , [syncchain](https://github.com/tiki/syncchain).

**Out of scope**  
-	Custom backup destination
-	Direct compensation (on-chain payment)
-	Secondary-market listing
-	Managed scopes (approved application wallets)
-	Platform specific SDKs (swift, kotlin, js, etc.)
-	Server-side SDK
-	Delegated consent management (SMS, email, etc.)

**API**   
Pseudo code language: Dart  
*note: Getters & setters are implicit in Dart* 

```
class TikiSdk{
 
  /// The origin that will be used as default origin for all ownership
  /// assignments. It should follow a reversed FQDN syntax.
  /// _i.e. com.mycompany.myproduct_
  String origin;

  /// The API Key for the TIKI public backup. If null, blocks will not
  /// be backed up. Register your application at mytiki.com to get your
  /// application’s API key.
  String? _apiKey;
 
  /// List of ids (wallet addresses) for the current user. The first
  /// id in the list with a known private key will become the primary
  /// chain, with all others operating in a read-only capacity.
  List<String>? _ids;
 
  TikiSdk(this.origin, {String? apiKey}) : this._apiKey = apiKey;
  
  Future<TikiSdk> init({List<String>? ids});
 
  List<String> get ids => _ids;
 
  void addId(String id);
 
  void removeId(String id);
 
  /// Assign ownership to a given [source] point, pool, or stream.
  /// [types] describe the various types of data represented by
  /// the referenced data. Optionally, the [origin] can be overridden
  /// for the specific ownership grant.
  Future<String> grantOwnership( 
    String source,
    SourceType type,
    List<DataType> contains,
    {String? origin, String? about}
  );
 
  /// Modify consent for [source]. Ownership must be granted before
  /// modifying consent. Consent is applied on an explicit only basis.
  /// Meaning all requests will be denied by default unless the
  /// destination is explicitly defined in [destinations].
  Future<String> modifyConsent(
    String source,
    List<Destination> destinations
  );
 
  /// Apply consent for [source] given a specific [destination].
  /// If consent exists for the destination, [request] will be
  /// executed. Else [onBlocked] is called.
  Future<void> applyConsent(
    String source, 
    Destination destination, 
    Function request,
    {void Function(String)? onBlocked}
  );
}
 
class Destination {
  
  /// An optional list of application specific uses cases 
  /// applicable to the given destination. Prefix with NOT
  /// to invert. _i.e. NOT ads
  List<String>? uses;
 
  /// A list of paths, preferably URL without the scheme or 
  /// reverse FQDN. Keep list short and use wildcard (*) 
  /// matching. Prefix with NOT to invert. 
  /// _i.e. NOT mytiki.com/*
  List<String> paths;
  String? about;
  String? reward;
 
  Destination(this.paths, {this.uses, this.about, this.reward});
}
 
enum DataType {
  emailAddress('email_address');
 
  const DataType(this.val);
 
  final String val;
}
 
enum SourceType {
  stream('stream');
 
  const SourceType(this.val);
 
  final String val;
}
```

**Initialization**  
When initializing the SDK, the wallet checks to see if there are private keys stored for each id (address). The first address with private keys located is configured as the primary chain (write), all other ids are configured as read only chains with their latest block loaded from the hosted backup and cached. If no private keys are located or a null id was provided during initialization, a new keypair is generated with an id (address) derived from the public key.

**Block construction**  
A new block is built:
1.	when the total size of the pending transactions block crosses 100KB.
2.	when a transaction is added, and the last block was constructed more than 1 min ago.
3.	on request.

To build a new block the SDK computes the [Merkel](https://en.wikipedia.org/wiki/Merkle_tree) root of the transaction hashes (SHA3-256). The block header and body are serialized and appended to the primary chain. Then the serialized block is backed up.  

**Cross chain reference**.  
For all non-primary ids, on first registration, the SDK will download and validate all blocks and transactions. All ownership transactions and the latest corresponding consent transaction will be added to the cache. Using the Merkle root in the block header, unnecessary transactions are discarded. After first launch, on open (or manually triggered), the SDK will download the latest blocks (if any) from any non-primary ids, updating the local cache. In the event of simultaneous consent-conflict, the latest and largest transaction prevails. 

**Cache tables**. 
-	decrypted transactions (if applicable) 
-	cross-chain block headers
-	cross-chain transactions (with Merkle proof) 
-	source – consent – ownership mapping

**Ownership grant**  
Customers are responsible for identifying their respective data source(s). Data sources should be unique per user —always preferring to reference an existing ownership grant and modifying the latest consent opposed to a new ownership grant. 

**Consent modification**  
Consent modification requires a reference to an existing ownership grant. The ownership grant transaction should be verified before the modification is minted. References may point to ownership on other chains (cross-chain). If so, the id corresponding to the chain must first be registered and the ownership cached locally.  

**Consent application**  
Consent application is a real-time check against the local consent cache using the data source as the unique identifier. If consent for the destination is permissible, the function is executed.

**Transaction encryption**  
Customers implementing the SDK can elect to encrypt an ownership grant or consent modification transaction using symmetrical (AES256) or asymmetrical (RSA2048) encryption. Private keys are stored alongside signature private keys in the on-device wallet. Default transactions are public (not encrypted).

**Block backup**  
Upon a block being successfully built and appended locally to the primary chain, the SDK immediately attempts to write the block to the shared backup repository in Wasabi using Object Lock. If the backup fails, the SDK will automatically try again up to 3 attempts. After which, on each sequential application launch and new block append, the failed block backup will be re-attempted. Backups use a public (read-only) URN structure of `/address_hex/block_hash/…` with write security handled by short-lived policies. To receive a short-lived policy, the SDK simply exchanges it’s API Key with the backup’s authorization service. A modifiable metadata file is added to the root of the backup chain under address_hex providing helpful information on latest block hashes and append timestamps. 

**Schema(s)**  
Pseudo code language: Dart  
*note: Actual transactions are serialized* 
```
class OwnershipNFT{
  String origin;
  String source;
  /// String value from SourceType
  String type;  
  /// Comma separated list of string values from DataType
  String contains;
  String? about;
  final String assetRef = '0x00';
 
  OwnershipNFT(this.origin, this.source, SourceType type, List<DataType> contains, {this.about});
}
 
class ConsentNFT{
  /// JSON formatted string from Destination object
  String destination;  
  String? about;
  String? reward;
  /// Transaction ID corresponding to the ownership mint
  /// for the data source 
  String assetRef;
 
  ConsentNFT(this.assetRef, Destination destination, {this.about, this.reward});
}
```
