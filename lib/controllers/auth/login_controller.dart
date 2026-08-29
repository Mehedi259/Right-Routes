import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:right_routes/core/routes/all_routes.dart';
import '../../../core/constants/services/auth_service.dart';
import 'package:right_routes/views/authentication/login_account/login_api_service/login_api_service.dart';

import 'package:right_routes/views/authentication/login_account/send_otp_service/Trouble_Login_Otp_service.dart';

/// ───────────────────────────────────────────────────────────
/// LoginController - GetX State Management
/// ───────────────────────────────────────────────────────────
class LoginController extends GetxController {
  final LoginApiService _apiService = LoginApiService();
  final TroubleLoginOtpService _troubleLoginService = TroubleLoginOtpService();

  // Observables
  final userEmail = ''.obs;
  final emailToken = ''.obs;
  final passwordText = ''.obs;
  final hidePassword = true.obs;
  final isLoading = false.obs;
  final isSendingOtp = false.obs;
  final isTouchIDEnabled = false.obs;
  
  // Biometric
  final canCheckBiometrics = false.obs;
  final isBiometricSupported = false.obs;
  final availableBiometrics = <BiometricType>[].obs;
  final LocalAuthentication auth = LocalAuthentication();

  // Text Controller
  final passwordController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    passwordController.addListener(() {
      passwordText.value = passwordController.text;
    });
    _loadUserData();
    initializeBiometrics();
  }

  /// Called after biometrics are initialized — auto-trigger if Touch ID enabled
  Future<void> _tryAutoTriggerBiometric() async {
    // Small delay to let UI settle before showing prompt
    await Future.delayed(const Duration(milliseconds: 800));
    if (isTouchIDEnabled.value &&
        availableBiometrics.isNotEmpty &&
        canCheckBiometrics.value) {
      final savedPassword = await AuthService.getUserPassword();
      if (savedPassword != null && savedPassword.isNotEmpty) {
        await authenticateWithBiometrics();
      }
    }
  }

  Future<void> _loadUserData() async {
    final args = Get.arguments;
    if (args != null) {
      userEmail.value = args['email'] ?? '';
      emailToken.value = args['token'] ?? '';
    }

    if (userEmail.value.isEmpty) {
      final savedEmail = AuthService.getUserEmail();
      if (savedEmail != null) userEmail.value = savedEmail;
    }

    if (emailToken.value.isEmpty) {
      final savedToken = await AuthService.getEmailToken();
      if (savedToken != null) emailToken.value = savedToken;
    }

    // Load Touch ID preference
    isTouchIDEnabled.value = AuthService.getTouchIDEnabled();
  }

  // ─── EMAIL MANAGEMENT ─────────────────────────────────────
  void setEmail(String email) {
    userEmail.value = email.trim();
    update();
  }

  void clearEmail() {
    userEmail.value = '';
  }

  // ─── PASSWORD VISIBILITY ──────────────────────────────────
  void togglePassword() {
    hidePassword.value = !hidePassword.value;
  }

  // ─── TOUCH ID TOGGLE ─────────────────────────────────────
  void toggleTouchID(bool value) {
    isTouchIDEnabled.value = value;
    AuthService.saveTouchIDEnabled(value); // Save the state
  }

  // ─── SEND OTP & NAVIGATE (Trouble Login) ──────────────────
  Future<void> sendOtpAndNavigate() async {
    if (userEmail.value.trim().isEmpty) {
      _showError('Email is required');
      return;
    }

    isSendingOtp.value = true;

    try {
      final result = await _troubleLoginService.sendOtp(email: userEmail.value);

      if (result['success'] == true) {
        _showSuccess(result['message'] ?? 'OTP sent to your email');
        await Future.delayed(const Duration(milliseconds: 500));

        Get.toNamed(
          AppRoutes.otpVerificationScreen,
          arguments: {
            'email': userEmail.value, 
            'purpose': 'TROUBLE_LOGIN', 
            'nextRoute': AppRoutes.weLoggedYou,
          },
        );
      } else {
        _showError(result['message'] ?? 'Failed to send OTP');
      }
    } catch (e) {
      _showError('Connection failed. Please try again.');
    } finally {
      isSendingOtp.value = false;
    }
  }

  // ─── LOGIN ────────────────────────────────────────────────
  Future<void> login() async {
    if (passwordController.text.trim().isEmpty) {
      _showError('Please enter password');
      return;
    }

    if (userEmail.value.isEmpty) {
      _showError('Email is missing. Please go back and enter email.');
      return;
    }

    isLoading.value = true;

    try {
      final result = await _apiService.login(
        email: userEmail.value,
        password: passwordController.text.trim(),
      );

      if (result['success'] == true) {
        final rawData = result['data'];
        final data = rawData['data'] ?? rawData;
        
        // Save tokens
        if (data['access'] != null) {
          await AuthService.saveAccessToken(data['access']);
        }
        if (data['refresh'] != null) {
          await AuthService.saveRefreshToken(data['refresh']);
        }

        // Save user data
        if (data['user'] != null) {
          final user = data['user'];
          if (user['email'] != null) {
            await AuthService.saveUserEmail(user['email']);
          }
          if (user['name'] != null) {
            await AuthService.saveUserName(user['name']);
          }
          if (user['id'] != null) {
            await AuthService.saveUserId(user['id'].toString());
          }
        }

        await AuthService.saveLoginStatus(true);
        await AuthService.saveUserEmail(userEmail.value);

        // Only save password if Touch ID is enabled (or we can always save it for biometric to work)
        // Since biometric uses local device security, it is safe to save it securely when enabled.
        if (isTouchIDEnabled.value) {
          await AuthService.saveUserPassword(passwordController.text.trim());
        } else {
          await AuthService.removeUserPassword();
        }

        _showSuccess(rawData['detail'] ?? 'Login successful!');

        Get.offAllNamed(AppRoutes.weLoggedYou);
      } else {
        _showError(result['message'] ?? 'Login failed');
      }
    } catch (e) {
      _showError('Connection failed. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }



  // ─── BIOMETRIC AUTH ───────────────────────────────────────
  Future<void> initializeBiometrics() async {
    await checkBiometricSupport();
    await checkAvailableBiometrics();
    // Auto-trigger fingerprint prompt if Touch ID was previously enabled
    await _tryAutoTriggerBiometric();
  }

  Future<void> checkBiometricSupport() async {
    try {
      canCheckBiometrics.value = await auth.canCheckBiometrics;
      isBiometricSupported.value = await auth.isDeviceSupported();
    } catch (e) {
      canCheckBiometrics.value = false;
      isBiometricSupported.value = false;
    }
  }

  Future<void> checkAvailableBiometrics() async {
    try {
      List<BiometricType> biometrics = await auth.getAvailableBiometrics();
      availableBiometrics.value = biometrics;
    } catch (e) {
      availableBiometrics.value = [];
    }
  }

  Future<bool> authenticateWithBiometrics() async {
    try {
      // Check if Touch ID was enabled by user first
      if (!isTouchIDEnabled.value) {
        _showWarning('Please enable Touch ID by logging in with your password first.');
        return false;
      }

      if (!canCheckBiometrics.value) {
        _showError('Biometric not available on this device');
        return false;
      }

      if (availableBiometrics.isEmpty) {
        _showWarning('Please set up fingerprint/Face ID in device settings');
        return false;
      }

      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Please authenticate to login to Right Routes',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
          useErrorDialogs: true,
          sensitiveTransaction: false,
        ),
      );

      if (didAuthenticate) {
        final savedPassword = await AuthService.getUserPassword();
        if (savedPassword != null && savedPassword.isNotEmpty) {
          passwordController.text = savedPassword;
          _showSuccess('Authentication successful!');
          await Future.delayed(const Duration(milliseconds: 800));
          await login();
          return true;
        } else {
          _showError('No saved password found. Please login normally first.');
          return false;
        }
      } else {
        _showError('Authentication failed. Please try again.');
        return false;
      }
    } catch (e) {
      _showError('Authentication error occurred');
      return false;
    }
  }

  // ─── SNACKBAR HELPERS ─────────────────────────────────────
  void _showError(String msg) {
    Get.snackbar('Error', msg,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2));
  }

  void _showSuccess(String msg) {
    Get.snackbar('Success', msg,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2));
  }

  void _showWarning(String msg) {
    Get.snackbar('Setup Required', msg,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2));
  }

  @override
  void onClose() {
    passwordController.dispose();
    super.onClose();
  }
}
