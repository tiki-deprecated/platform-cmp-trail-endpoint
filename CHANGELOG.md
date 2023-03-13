### 2.0.1
**Expands the API to:**
- Allow customer provided IDs (instead of directly utilizing addresses)
- Allow customers to provide their own user token (JWT) for added registry security

**Adds logic to:**
- Sync all transactions for all addresses registered to the ID on startup
- Auto-register new addresses created to the ID
- Add an app signature (using sign key from registry) to transactions
- Interface with the l0-registry service

### 2.0.0
**Node**
- Set `maxTransactions` default to 1 (_Most applications do not require high throughput, and longer chains will improve the immutability strength_)

**Ownership**
- Rename ownership to title (_As in "Title Record", the standard name used for declaring asset ownership._)
- Rename source to ptr (_Stands for Pointer Record and is more explicit about its intended use._)
- Rename about to description
- Remove type (`TikiSdkDataTypeEnum`) (_They're more confusing than helpful and not critical to use._)
- Title records should ALWAYS have an assetRef of 0x00 ("mint" transaction")
- Update schema from `1` to an Enum AND bump version (_Contents body schema is changing shape._)
- Rename contains to tags (_Both more explicit and flexible._)
- Use Enum for tags, defined [here](https://docs.mytiki.com/docs/adding-tags)

**Consent**
- Rename consent to license (_As in "License Record", a more explicit and standard name_)
- Bug: Schema is not serialized (_Fix and use an Enum_)
- OwnershipId should be in the assetRef field, not in the contents (_See whitepaper_)
- Rename about to description
- Rename destination to uses, and update object structure to match [spec](https://docs.mytiki.com/docs/specifying-terms-and-usage).
- Bug: Fix destination/uses serialization. (_for example, `[],[]` currently resolves to `[][]`_)

**SDK**
- Update method names to match naming changes from above
- Rename `applyConsent` to `guard` and adjust functionality to match [spec](https://docs.mytiki.com/docs/enforce-license)
- Update `_checkConsent` logic to match new uses data structure

### 1.1.2

* Add example app (in progress)
* Change description
* Update TIKI SDK public API docs

## 1.1.1

* bump version for Dart Pub sync

## 1.1.0

* new L0 Auth and L0 Storage APIs
* new test and release flow
* dart doc categories and topics
* move consent & ownership into a cache category

## 1.0.0

* public release

## 0.0.18

* fix apply consent errors
* add more tests for apply consent

## 0.0.17

* fix bugs with json convert
* add expiry to ConsentModel repository

## 0.0.16

* add toJson to ownership and consent models

## 0.0.12 - 0.0.15

* docs updates

## 0.0.11

* fix destination deserialization

## 0.0.10
* updated README
* fixed apiId naming

## 0.0.9
* expose utils/bytes lib
* update sstorage 

## 0.0.8

* code cleanup
* documentation updates
* tests updates

## 0.0.7

* add toJson to consent and destination models
* change backup key path

## 0.0.6

* update to builder pattern

## 0.0.5

* TIKI SDK methods implementation
## 0.0.4

* Add xchain
* Add NFT layer (consent and ownership)
## 0.0.3

* Update lib structure
* Add doc
## 0.0.2

* Blockchain local node
## 0.0.1

* Setup repository
