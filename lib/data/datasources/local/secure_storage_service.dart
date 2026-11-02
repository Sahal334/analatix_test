import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:analatix_flutter_test_muhammedsahal/core/constants/app_constants.dart';

class SecureStorageService {
  SecureStorageService()
      : _storage = const FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
        );

  final FlutterSecureStorage _storage;

  Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: AppConstants.tokenKey, value: token);
    } catch (_) {}
  }

  Future<void> saveRefreshToken(String token) async {
    try {
      await _storage.write(key: AppConstants.refreshTokenKey, value: token);
    } catch (_) {}
  }

  Future<void> saveUsername(String username) async {
    try {
      await _storage.write(key: AppConstants.usernameKey, value: username);
    } catch (_) {}
  }

  Future<String?> getToken() async {
    try {
      return await _storage.read(key: AppConstants.tokenKey);
    } catch (_) {
      return null;
    }
  }

  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: AppConstants.refreshTokenKey);
    } catch (_) {
      return null;
    }
  }

  Future<String?> getUsername() async {
    try {
      return await _storage.read(key: AppConstants.usernameKey);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveBiometricCredentials({
    required String username,
    required String password,
  }) async {
    try {
      await _storage.write(
        key: AppConstants.biometricUsernameKey,
        value: username,
      );
      await _storage.write(
        key: AppConstants.biometricPasswordKey,
        value: password,
      );
    } catch (_) {}
  }

  Future<Map<String, String>?> getBiometricCredentials() async {
    try {
      final username =
          await _storage.read(key: AppConstants.biometricUsernameKey);
      final password =
          await _storage.read(key: AppConstants.biometricPasswordKey);
      if (username != null &&
          password != null &&
          username.isNotEmpty &&
          password.isNotEmpty) {
        return {'username': username, 'password': password};
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<bool> hasBiometricCredentials() async {
    final creds = await getBiometricCredentials();
    return creds != null;
  }

  Future<void> clearSession() async {
    try {
      await _storage.delete(key: AppConstants.tokenKey);
      await _storage.delete(key: AppConstants.refreshTokenKey);
    } catch (_) {}
  }

  Future<void> clearBiometricCredentials() async {
    try {
      await _storage.delete(key: AppConstants.biometricUsernameKey);
      await _storage.delete(key: AppConstants.biometricPasswordKey);
    } catch (_) {}
  }

  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (_) {}
  }
}
