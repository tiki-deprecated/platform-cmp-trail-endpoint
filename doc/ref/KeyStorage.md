---
title: KeyStorage
excerpt: The interface for KeyModel persistance class.
category: 6379d3b069658a0031973026
slug: tiki-sdk-dart-key-storage
hidden: false
order: 3
---

The implementation should use OS level encrypted storage. It should not be
accessible to other applications or users because it will store the private
keys of the user, which is required for write operations in the chain.  

- [EncryptedSharedPreferences](https://developer.android.com/reference/androidx/security/crypto/EncryptedSharedPreferences) should be used for Android. AES encryption is
another option with AES secret key encrypted with RSA and RSA key stored
in KeyStore.


- [Keychain](href="https://developer.apple.com/documentation/security/keychain_services) is recommended for iOS and MacOS.


- For Linux [libsecret](https://gitlab.gnome.org/GNOME/libsecret">https://gitlab.gnome.org/GNOME/libsecret) is a reliable option.


- In JavaScript web environments the recommendation is [WebCrypto](https://developer.mozilla.org/pt-BR/docs/Web/API/Web_Crypto_API) with HTST enabled.


- In other environments, use equivalent implementations of the recommended ones.</p>

## Constructors

##### KeyStorage()

## Methods

##### read({required String key}) &#8594; Future&lt;String?>

##### write({required String key, required String value}) &#8594; Future&lt;void>














