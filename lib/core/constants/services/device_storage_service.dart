import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DeviceStorageService extends GetxService {
  // Instances
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  // Storage Keys
  static const String _keyDeviceId = 'device_id';
  static const String _keyAccessToken = 'access_token';
  static const String _keyTrustedStatus = 'trusted_status';

  // ═══════════════════════════════════════════════════════════════════════════
  // DEVICE ID EXTRACTION
  // ═══════════════════════════════════════════════════════════════════════════

  /// Extracts the unique device identifier using device_info_plus.
  Future<String?> _extractDeviceId() async {
    try {
      if (Platform.isAndroid) {
        final AndroidDeviceInfo androidInfo = await _deviceInfo.androidInfo;
        // Since androidInfo.id is just the Build ID (not unique per device),
        // we create a pseudo-unique ID by combining model and a timestamp.
        // It will be saved in Secure Storage and persist across sessions.
        return 'android_${androidInfo.model.replaceAll(RegExp(r'\s+'), '_')}_${DateTime.now().millisecondsSinceEpoch}';
      } else if (Platform.isIOS) {
        final IosDeviceInfo iosInfo = await _deviceInfo.iosInfo;
        return iosInfo.identifierForVendor;
      }
      return null;
    } catch (e) {
      debugPrint('❌ [DeviceStorageService] Error extracting Device ID: $e');
      return null;
    }
  }

  /// Gets the device ID. If it isn't stored in secure storage yet, 
  /// it extracts it, saves it, and then returns it.
  Future<String?> getOrCreateDeviceId() async {
    try {
      String? storedDeviceId = await readDeviceId();
      
      if (storedDeviceId == null || storedDeviceId.isEmpty) {
        // Extract and Save
        storedDeviceId = await _extractDeviceId();
        if (storedDeviceId != null) {
          await saveDeviceId(storedDeviceId);
        }
      }
      return storedDeviceId;
    } catch (e) {
      debugPrint('❌ [DeviceStorageService] Error getting/creating Device ID: $e');
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SECURE STORAGE WRAPPERS (SAVE)
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> saveDeviceId(String deviceId) async {
    try {
      await _secureStorage.write(key: _keyDeviceId, value: deviceId);
      debugPrint('✅ [DeviceStorageService] Device ID saved');
    } catch (e) {
      debugPrint('❌ [DeviceStorageService] Error saving Device ID: $e');
    }
  }

  Future<void> saveAccessToken(String token) async {
    try {
      await _secureStorage.write(key: _keyAccessToken, value: token);
      debugPrint('✅ [DeviceStorageService] Access Token saved');
    } catch (e) {
      debugPrint('❌ [DeviceStorageService] Error saving Access Token: $e');
    }
  }

  Future<void> saveTrustedStatus(bool isTrusted) async {
    try {
      await _secureStorage.write(key: _keyTrustedStatus, value: isTrusted.toString());
      debugPrint('✅ [DeviceStorageService] Trusted Status saved: $isTrusted');
    } catch (e) {
      debugPrint('❌ [DeviceStorageService] Error saving Trusted Status: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SECURE STORAGE WRAPPERS (READ)
  // ═══════════════════════════════════════════════════════════════════════════

  Future<String?> readDeviceId() async {
    try {
      return await _secureStorage.read(key: _keyDeviceId);
    } catch (e) {
      debugPrint('❌ [DeviceStorageService] Error reading Device ID: $e');
      return null;
    }
  }

  Future<String?> readAccessToken() async {
    try {
      return await _secureStorage.read(key: _keyAccessToken);
    } catch (e) {
      debugPrint('❌ [DeviceStorageService] Error reading Access Token: $e');
      return null;
    }
  }

  Future<bool> readTrustedStatus() async {
    try {
      final status = await _secureStorage.read(key: _keyTrustedStatus);
      return status == 'true';
    } catch (e) {
      debugPrint('❌ [DeviceStorageService] Error reading Trusted Status: $e');
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SECURE STORAGE WRAPPERS (DELETE / CLEAR)
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> deleteAccessToken() async {
    try {
      await _secureStorage.delete(key: _keyAccessToken);
      debugPrint('🗑️ [DeviceStorageService] Access Token deleted');
    } catch (e) {
      debugPrint('❌ [DeviceStorageService] Error deleting Access Token: $e');
    }
  }

  /// Clears all stored data (typically used during Logout)
  Future<void> clearAllStorage() async {
    try {
      await _secureStorage.deleteAll();
      debugPrint('🗑️ [DeviceStorageService] All secure storage cleared');
    } catch (e) {
      debugPrint('❌ [DeviceStorageService] Error clearing storage: $e');
    }
  }
}
