import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:right_routes/core/constants/api_config/api_config.dart';
import 'package:right_routes/core/constants/services/api_client.dart';
import 'package:right_routes/core/constants/services/auth_service.dart';
import 'package:right_routes/core/routes/all_routes.dart';

/// ─────────────────────────────────────────────────────────────
/// AccountDeleteController
/// Handles account deletion via POST /auth/account-delete/
/// ─────────────────────────────────────────────────────────────
class AccountDeleteController extends GetxController {
  final isDeleting = false.obs;

  /// Call this when user clicks "YES, DELETE THIS ACCOUNT" on the screen
  Future<void> deleteAccount() async {
    isDeleting.value = true;

    try {
      final url = Uri.parse(ApiConfig.fullAccountDeleteUrl);
      print('[DELETE-ACCOUNT] POST $url');

      final response = await ApiClient.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: {},
        requireAuth: true, // Bearer Token required
      );

      print('[DELETE-ACCOUNT] Status: ${response.statusCode} | Body: ${response.data}');

      if (response.statusCode == 200 ||
          response.statusCode == 204 ||
          response.statusCode == 201) {
        // Success — clear all local data and navigate
        await _clearAllDataAndNavigate();
      } else {
        final data = response.data;
        final message = _extractError(data, 'Failed to delete account');
        _showError(message);
        isDeleting.value = false;
      }
    } catch (e) {
      print('[DELETE-ACCOUNT] ERROR: $e');
      _showError('Network error. Please check your connection.');
      isDeleting.value = false;
    }
  }

  /// Clear all local data after successful deletion
  Future<void> _clearAllDataAndNavigate() async {
    // Clear ALL data including password & Touch ID
    // (account is permanently deleted, no biometric needed anymore)
    await AuthService.clearAllTokens();
    await AuthService.clearUserData();
    await AuthService.saveTouchIDEnabled(false);
    await AuthService.saveLoginStatus(false);

    // Force clear GetX controllers
    Get.deleteAll(force: true);

    // Navigate to account deleted confirmation screen
    // (account_delete.dart shows "Your account has been deleted" message)
    Get.offAllNamed(AppRoutes.accountDelete);
  }

  String _extractError(dynamic data, String fallback) {
    try {
      if (data is Map) {
        if (data['detail'] != null) return data['detail'].toString();
        if (data['message'] != null) return data['message'].toString();
        if (data['error'] != null) return data['error'].toString();
      }
      return fallback;
    } catch (_) {
      return fallback;
    }
  }

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
  }
}
