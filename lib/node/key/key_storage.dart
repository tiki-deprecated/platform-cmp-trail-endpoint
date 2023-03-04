/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

/// The interface for platform-specific private key persistance.
///
/// The implementation should use OS level encrypted storage. It should not be
/// accessible to other applications or users because it will store the private
/// keys of the user, which is required for write operations in the chain.
///
/// EncryptedSharedPreferences should be used for Android. AES encryption is
/// another option with AES secret key encrypted with RSA and RSA key stored
/// in KeyStore.
/// See https://developer.android.com/reference/androidx/security/crypto/EncryptedSharedPreferences
///
/// Keychain is recommended for iOS and MacOS.
/// See https://developer.apple.com/documentation/security/keychain_services
///
/// For Linux libsecret is a reliable option.
/// See https://gitlab.gnome.org/GNOME/libsecret
///
/// In JavaScript web environments the recommendation is WebCrypto with HTST enabled.
/// See https://developer.mozilla.org/pt-BR/docs/Web/API/Web_Crypto_API
///
/// In other environments, use equivalent implementations of the recommended ones.
abstract class KeyStorage {
  Future<void> write({required String key, required String value});

  Future<String?> read({required String key});
}
