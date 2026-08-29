import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

class AuthService {
  static SharedPreferences? _prefs;
  static const _secureStorage = FlutterSecureStorage();

  // Initialize
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    print('✅ AuthService Initialized');
  }

  // ═══════════════════════════════════════════════════════════
  // 🔐 TOKEN MANAGEMENT (Secure Storage)
  // ═══════════════════════════════════════════════════════════

  // Save Access Token (Secure)
  static Future<void> saveAccessToken(String token) async {
    print('🔐 Saving Access Token (Secure)');
    await _secureStorage.write(key: 'access_token', value: token);
    print('✅ Access Token Saved');
  }

  // Get Access Token
  static Future<String?> getAccessToken() async {
    final token = await _secureStorage.read(key: 'access_token');
    print('📤 Getting Access Token: ${token != null ? "Found" : "Not Found"}');
    return token;
  }

  // Save Refresh Token (Secure)
  static Future<void> saveRefreshToken(String token) async {
    print('🔐 Saving Refresh Token (Secure)');
    await _secureStorage.write(key: 'refresh_token', value: token);
    print('✅ Refresh Token Saved');
  }

  // Get Refresh Token
  static Future<String?> getRefreshToken() async {
    final token = await _secureStorage.read(key: 'refresh_token');
    print('📤 Getting Refresh Token: ${token != null ? "Found" : "Not Found"}');
    return token;
  }

  // Save Email Token (Secure)
  static Future<void> saveEmailToken(String token) async {
    print('🔐 Saving Email Token (Secure)');
    await _secureStorage.write(key: 'email_token', value: token);
    print('✅ Email Token Saved');
  }

  // Get Email Token
  static Future<String?> getEmailToken() async {
    final token = await _secureStorage.read(key: 'email_token');
    print('📤 Getting Email Token: ${token != null ? "Found" : "Not Found"}');
    return token;
  }

  // Clear All Tokens (Secure)
  static Future<void> clearAllTokens() async {
    print('🗑️ Clearing all tokens from Secure Storage');
    await _secureStorage.deleteAll();
    print('✅ All tokens cleared');
  }

  // Save User Password (Secure)
  static Future<void> saveUserPassword(String password) async {
    print('🔐 Saving User Password (Secure)');
    await _secureStorage.write(key: 'user_password', value: password);
    print('✅ User Password Saved');
  }

  // Get User Password
  static Future<String?> getUserPassword() async {
    final password = await _secureStorage.read(key: 'user_password');
    print('📤 Getting User Password: ${password != null ? "Found" : "Not Found"}');
    return password;
  }

  // Remove User Password
  static Future<void> removeUserPassword() async {
    print('🗑️ Removing User Password (Secure)');
    await _secureStorage.delete(key: 'user_password');
  }

  // ═══════════════════════════════════════════════════════════
  // 👤 USER DATA MANAGEMENT (SharedPreferences)
  // ═══════════════════════════════════════════════════════════

  // Save User Email
  static Future<bool> saveUserEmail(String email) async {
    print('💾 Saving User Email: $email');
    return await _prefs?.setString('user_email', email) ?? false;
  }

  // Get User Email
  static String? getUserEmail() {
    final email = _prefs?.getString('user_email');
    print('📤 Getting User Email: $email');
    return email;
  }

  // Save Device User Email (from device-info check)
  static Future<bool> saveDeviceUserEmail(String email) async {
    print('💾 Saving Device User Email: $email');
    return await _prefs?.setString('device_user_email', email) ?? false;
  }

  // Get Device User Email
  static String? getDeviceUserEmail() {
    final email = _prefs?.getString('device_user_email');
    print('📤 Getting Device User Email: $email');
    return email;
  }

  // Save User Name
  static Future<bool> saveUserName(String name) async {
    print('💾 Saving User Name: $name');
    return await _prefs?.setString('user_name', name) ?? false;
  }

  // Get User Name
  static String? getUserName() {
    final name = _prefs?.getString('user_name');
    print('📤 Getting User Name: $name');
    return name;
  }

  // Save User ID
  static Future<bool> saveUserId(String id) async {
    print('💾 Saving User ID: $id');
    return await _prefs?.setString('user_id', id) ?? false;
  }

  // Get User ID
  static String? getUserId() {
    final id = _prefs?.getString('user_id');
    print('📤 Getting User ID: $id');
    return id;
  }

  // Save User Phone
  static Future<bool> saveUserPhone(String phone) async {
    print('💾 Saving User Phone: $phone');
    return await _prefs?.setString('user_phone', phone) ?? false;
  }

  // Get User Phone
  static String? getUserPhone() {
    final phone = _prefs?.getString('user_phone');
    print('📤 Getting User Phone: $phone');
    return phone;
  }

  // ═══════════════════════════════════════════════════════════
  // 📍 APP ROUTE & DRAFT STATE PERSISTENCE
  // ═══════════════════════════════════════════════════════════

  static Future<void> saveLastRoute(String routeName, {Map<String, dynamic>? arguments}) async {
    print('💾 Saving Last Route: $routeName');
    await _prefs?.setString('last_active_route', routeName);
    if (arguments != null) {
      await _prefs?.setString('last_active_route_args', jsonEncode(arguments));
    } else {
      await _prefs?.remove('last_active_route_args');
    }
  }

  static String? getLastRoute() {
    return _prefs?.getString('last_active_route');
  }

  static Map<String, dynamic>? getLastRouteArgs() {
    final argsStr = _prefs?.getString('last_active_route_args');
    if (argsStr != null && argsStr.isNotEmpty) {
      try {
        return jsonDecode(argsStr) as Map<String, dynamic>;
      } catch (e) {
        print('❌ Error decoding route args: $e');
      }
    }
    return null;
  }

  static Future<void> saveDraftRouteData(String key, Map<String, dynamic> data) async {
    await _prefs?.setString('draft_route_data_$key', jsonEncode(data));
  }

  static Map<String, dynamic>? getDraftRouteData(String key) {
    final str = _prefs?.getString('draft_route_data_$key');
    if (str != null && str.isNotEmpty) {
      try {
        return jsonDecode(str) as Map<String, dynamic>;
      } catch (e) {}
    }
    return null;
  }

  static Future<void> clearDraftRouteData(String key) async {
    await _prefs?.remove('draft_route_data_$key');
  }

  static Future<void> clearAllDraftsAndRoutes() async {
    await _prefs?.remove('last_active_route');
    await _prefs?.remove('last_active_route_args');
    // Clear known draft keys
    await _prefs?.remove('draft_route_data_home');
    await _prefs?.remove('draft_route_data_after_confirm');
  }

  // ═══════════════════════════════════════════════════════════
  // 🔐 TOUCH ID ENABLED
  // ═══════════════════════════════════════════════════════════

  // Save Touch ID Enabled State
  static Future<bool> saveTouchIDEnabled(bool enabled) async {
    print('💾 Saving Touch ID Enabled: $enabled');
    return await _prefs?.setBool('touch_id_enabled', enabled) ?? false;
  }

  // Get Touch ID Enabled State
  static bool getTouchIDEnabled() {
    final enabled = _prefs?.getBool('touch_id_enabled') ?? false;
    print('📤 Getting Touch ID Enabled: $enabled');
    return enabled;
  }

  // ═══════════════════════════════════════════════════════════
  // 📧 EMAIL CHANGE MANAGEMENT
  // ═══════════════════════════════════════════════════════════

  // Save Old Email (before change) - Backup purpose
  static Future<bool> saveOldEmail(String email) async {
    print('💾 Saving Old Email (Backup): $email');
    return await _prefs?.setString('old_email', email) ?? false;
  }

  // Get Old Email
  static String? getOldEmail() {
    final email = _prefs?.getString('old_email');
    print('📤 Getting Old Email: $email');
    return email;
  }

  // Save Pending Email (waiting for verification)
  static Future<bool> savePendingEmail(String email) async {
    print('💾 Saving Pending Email: $email');
    return await _prefs?.setString('pending_email', email) ?? false;
  }

  // Get Pending Email
  static String? getPendingEmail() {
    final email = _prefs?.getString('pending_email');
    print('📤 Getting Pending Email: $email');
    return email;
  }

  // Update User Email (after successful change)
  static Future<bool> updateUserEmail(String newEmail) async {
    print('');
    print('═══════════════════════════════════════════════════');
    print('📧 UPDATING USER EMAIL IN AUTHSERVICE');
    print('═══════════════════════════════════════════════════');

    // Get old email first
    final oldEmail = getUserEmail();
    print('📤 Old Email: $oldEmail');
    print('📥 New Email: $newEmail');

    // Save old email as backup
    if (oldEmail != null) {
      await saveOldEmail(oldEmail);
    }

    // Update to new email
    final result = await saveUserEmail(newEmail);

    // Clear pending email
    await _prefs?.remove('pending_email');

    if (result) {
      print('✅ Email updated successfully in AuthService');
    } else {
      print('❌ Failed to update email in AuthService');
    }

    return result;
  }

  // Clear Email Change Data (after completion or cancellation)
  static Future<void> clearEmailChangeData() async {
    print('🗑️ Clearing email change data');
    await _prefs?.remove('old_email');
    await _prefs?.remove('pending_email');
    print('✅ Email change data cleared');
  }

  // Restore Old Email (in case of failure)
  static Future<bool> restoreOldEmail() async {
    print('🔄 Restoring old email');
    final oldEmail = getOldEmail();

    if (oldEmail != null) {
      final result = await saveUserEmail(oldEmail);
      await clearEmailChangeData();
      print('✅ Old email restored: $oldEmail');
      return result;
    } else {
      print('❌ No old email to restore');
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // 🔑 AUTHENTICATION STATUS
  // ═══════════════════════════════════════════════════════════

  // Save Login Status
  static Future<bool> saveLoginStatus(bool isLoggedIn) async {
    print('💾 Saving Login Status: $isLoggedIn');
    return await _prefs?.setBool('is_logged_in', isLoggedIn) ?? false;
  }

  // Check if User is Logged In
  static bool isLoggedIn() {
    final status = _prefs?.getBool('is_logged_in') ?? false;
    print('📤 Checking Login Status: $status');
    return status;
  }

  // Save User Exists Status
  static Future<bool> saveUserExists(bool exists) async {
    print('💾 Saving User Exists: $exists');
    return await _prefs?.setBool('user_exists', exists) ?? false;
  }

  // Get User Exists Status
  static bool getUserExists() {
    final exists = _prefs?.getBool('user_exists') ?? false;
    print('📤 Getting User Exists: $exists');
    return exists;
  }

  // ═══════════════════════════════════════════════════════════
  // 🚪 LOGOUT & CLEAR DATA
  // ═══════════════════════════════════════════════════════════

  // Clear Only Auth Tokens (NOT password)
  static Future<void> clearAuthTokens() async {
    print('🗑️ Clearing auth tokens only (keeping saved password)');
    await _secureStorage.delete(key: 'access_token');
    await _secureStorage.delete(key: 'refresh_token');
    await _secureStorage.delete(key: 'email_token');
    print('✅ Auth tokens cleared');
  }

  // Logout (Clear everything EXCEPT Touch ID setting & saved password if enabled)
  static Future<void> logout() async {
    print('');
    print('═══════════════════════════════════════════════════');
    print('🚪 LOGGING OUT...');
    print('═══════════════════════════════════════════════════');

    // Check if Touch ID was enabled before clearing
    final bool touchIDEnabled = getTouchIDEnabled();
    final String? savedEmail = getUserEmail();

    // Clear secure auth tokens ONLY (keep saved password for biometric)
    await clearAuthTokens();

    // Clear SharedPreferences user data
    await _prefs?.clear();

    // If Touch ID was enabled: restore the settings so biometric works next login
    if (touchIDEnabled) {
      print('🔐 Touch ID enabled — restoring biometric settings after logout');
      await saveTouchIDEnabled(true);
      // Also restore the email so login screen shows the correct email
      if (savedEmail != null && savedEmail.isNotEmpty) {
        await saveUserEmail(savedEmail);
      }
    }

    // Clear GetX memory cache (force delete all permanent controllers)
    Get.deleteAll(force: true);

    print('✅ Logout Complete');
    if (touchIDEnabled) {
      print('   Touch ID setting & password kept for biometric login');
    } else {
      print('   All data cleared');
    }
    print('═══════════════════════════════════════════════════');
    print('');
  }

  // Clear only user data (keep tokens)
  static Future<void> clearUserData() async {
    print('🗑️ Clearing user data only (keeping tokens)');
    await _prefs?.remove('user_email');
    await _prefs?.remove('user_name');
    await _prefs?.remove('user_id');
    await _prefs?.remove('user_phone');
    await _prefs?.remove('user_exists');
    await clearEmailChangeData();
    print('✅ User data cleared');
  }

  // ═══════════════════════════════════════════════════════════
  // 📊 HELPER METHODS
  // ═══════════════════════════════════════════════════════════

  // Save Complete User Info (after login/register)
  static Future<void> saveUserInfo({
    required String email,
    String? name,
    String? id,
    String? phone,
    String? password,
    String? accessToken,
    String? refreshToken,
  }) async {
    print('');
    print('═══════════════════════════════════════════════════');
    print('💾 SAVING COMPLETE USER INFO');
    print('═══════════════════════════════════════════════════');

    // Save user data
    await saveUserEmail(email);
    if (name != null) await saveUserName(name);
    if (id != null) await saveUserId(id);
    if (phone != null) await saveUserPhone(phone);

    // Save tokens and password securely
    if (accessToken != null) await saveAccessToken(accessToken);
    if (refreshToken != null) await saveRefreshToken(refreshToken);
    if (password != null) await saveUserPassword(password);

    // Set login status
    await saveLoginStatus(true);

    print('✅ Complete user info saved');
    print('═══════════════════════════════════════════════════');
    print('');
  }

  // Get all user info (for debugging)
  static Future<Map<String, dynamic>> getAllUserInfo() async {
    return {
      'email': getUserEmail(),
      'name': getUserName(),
      'id': getUserId(),
      'phone': getUserPhone(),
      'isLoggedIn': isLoggedIn(),
      'userExists': getUserExists(),
      'hasAccessToken': await getAccessToken() != null,
      'hasRefreshToken': await getRefreshToken() != null,
      'hasEmailToken': await getEmailToken() != null,
      'oldEmail': getOldEmail(),
      'pendingEmail': getPendingEmail(),
    };
  }

  // Print all user info (debug)
  static Future<void> printUserInfo() async {
    final info = await getAllUserInfo();
    print('');
    print('═══════════════════════════════════════════════════');
    print('👤 USER INFO (DEBUG)');
    print('═══════════════════════════════════════════════════');
    info.forEach((key, value) {
      print('   $key: $value');
    });
    print('═══════════════════════════════════════════════════');
    print('');
  }
}
