---
title: KeyStorage
excerpt: The interface for private key storage. Requires platform-specific implementation.
category: 6379d3b069658a0031973026
slug: tiki-sdk-dart-key-storage
hidden: false
order: 3
---

Implementations should use OS level encrypted storage. It should not be
accessible to other applications or users. Storage is a Key-Value store used for private
keys. Required for chain write operations.  

- **Android: [EncryptedSharedPreferences](https://developer.android.com/reference/androidx/security/crypto/EncryptedSharedPreferences)**
Alternatively with AES secret key encrypted with RSA and RSA key stored in [KeyStore](https://developer.android.com/training/articles/keystore.html).


- **iOS and MacOS: [Keychain](href="https://developer.apple.com/documentation/security/keychain_services)**


- **Linux: [libsecret](https://gitlab.gnome.org/GNOME/libsecret">https://gitlab.gnome.org/GNOME/libsecret)**


- **Web (JS): [WebCrypto](https://developer.mozilla.org/pt-BR/docs/Web/API/Web_Crypto_API) + [IndexedDB](https://developer.mozilla.org/en-US/docs/Web/API/IndexedDB_API)**   
Make sure to enable HTTP Strict Forward Secrecy (HTST) to avoid js hijacking.


## Constructors

##### KeyStorage()

## Methods

##### read({required String key}) &#8594; Future&lt;String?>  
Reads the stored key using a lookup `key`.

##### write({required String key, required String value}) &#8594; Future&lt;void>
Writes a key to storage under a lookup `key`.

The stored key format is the following JSON string:
```
{
    'address': Base64(address),
    'private_key': Base64(PKCS8(privateKey)
}
```

With the lookup key as: `com.mytiki.sdk.<address>`





