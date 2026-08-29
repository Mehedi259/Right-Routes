/// API Configuration for Right Routes App
/// Manages different API endpoints for development and production
class ApiConfig {
  // ========== ENVIRONMENT TOGGLE ==========
  /// Set to true for development, false for production
  static const bool isDevelopment = true;

  // ========== DEVICE TYPE CONFIGURATION ==========
  /// Change this based on where you're testing
  static const DeviceType currentDevice = DeviceType.realDevice;

  // ========== BASE URLs ==========
  static String get baseUrl {
    if (isDevelopment) {
      // Development URLs
      switch (currentDevice) {
        case DeviceType.androidEmulator:
          return 'http://54.236.158.228:8003/api/v1'; // Android emulator
        case DeviceType.iosSimulator:
          return 'http://54.236.158.228:8003/api/v1'; // iOS simulator
        case DeviceType.realDevice:
          return 'http://54.236.158.228:8003/api/v1'; // Your actual backend IP
      }
    } else {
      // Production URL
      return 'https://api.rightroutes.com'; // Replace with your production domain
    }
  }

  // =========================================================================
  //                              API ENDPOINTS
  // =========================================================================

  // ─── AUTHENTICATION ────────────────────────────────────────────────────────
  static const String loginEndpoint = '/auth/login/';
  static const String registerEndpoint = '/auth/register/';
  static const String logoutEndpoint = '/auth/logout/';
  static const String createPasswordEndpoint = '/auth/create-password/';
  static const String verifyTokenEndpoint = '/auth/verify-token/';
  static const String refreshTokenEndpoint = '/auth/refresh-token/';

  // ─── OTP & EMAIL VERIFICATION ──────────────────────────────────────────────
  static const String requestOtpEndpoint = '/auth/request-otp/';
  static const String resendOtpEndpoint = '/auth/resend-otp/';
  static const String verifyOtpEndpoint = '/auth/verify-otp/';
  static const String checkEmailEndpoint = '/auth/continue/';
  static const String directLoginOtpSendEndpoint = '/auth/direct-login/otp-send/';
  static const String directLoginOtpVerifyEndpoint = '/auth/direct-login/otp-verification/';

  // ─── USER PROFILE & ACCOUNT ────────────────────────────────────────────────
  static const String profileEndpoint = '/auth/profile/';
  static const String userInfoEndpoint = '/userinfo/';
  static const String changeEmailEndpoint = '/auth/change-email/';
  static const String changePasswordEndpoint = '/auth/change-password/';
  static const String accountDeleteEndpoint = '/auth/account-delete/';
  
  // ─── SUBSCRIPTION & BILLING ────────────────────────────────────────────────
  static const String currentPlanEndpoint = '/subscription/current-plan/';

  // ─── OTHER FEATURES ────────────────────────────────────────────────────────
  static const String processOcrEndpoint = '/auth/api/process-ocr/';


  // =========================================================================
  //                              FULL URLs
  // =========================================================================

  // Auth URLs
  static String get fullLoginUrl => '$baseUrl$loginEndpoint';
  static String get fullRegisterUrl => '$baseUrl$registerEndpoint';
  static String get fullLogoutUrl => '$baseUrl$logoutEndpoint';
  static String get fullCreatePasswordUrl => '$baseUrl$createPasswordEndpoint';
  static String get fullVerifyTokenUrl => '$baseUrl$verifyTokenEndpoint';
  static String get fullRefreshTokenUrl => '$baseUrl$refreshTokenEndpoint';

  // OTP URLs
  static String get fullRequestOtpUrl => '$baseUrl$requestOtpEndpoint';
  static String get fullResendOtpUrl => '$baseUrl$resendOtpEndpoint';
  static String get fullVerifyOtpUrl => '$baseUrl$verifyOtpEndpoint';
  static String get fullCheckEmailUrl => '$baseUrl$checkEmailEndpoint';
  static String get fullDirectLoginOtpSendUrl => '$baseUrl$directLoginOtpSendEndpoint';
  static String get fullDirectLoginOtpVerifyUrl => '$baseUrl$directLoginOtpVerifyEndpoint';

  // Profile URLs
  static String get fullProfileUrl => '$baseUrl$profileEndpoint';
  static String get fullUserInfoUrl => '$baseUrl$userInfoEndpoint';
  static String get fullChangeEmailUrl => '$baseUrl$changeEmailEndpoint';
  static String get fullChangePasswordUrl => '$baseUrl$changePasswordEndpoint';
  static String get fullAccountDeleteUrl => '$baseUrl$accountDeleteEndpoint';

  // Subscription URLs
  static String get fullCurrentPlanUrl => '$baseUrl$currentPlanEndpoint';

  // Other URLs
  static String get fullOcrUrl => '$baseUrl$processOcrEndpoint';
  static String get fullUrl => fullOcrUrl; 
  // ========== TIMEOUT CONFIGURATIONS ==========
  static const Duration connectionTimeout = Duration(seconds: 60);
  static const Duration receiveTimeout = Duration(seconds: 60);

  // ========== FILE UPLOAD LIMITS ==========
  static const int maxFileSize = 10 * 1024 * 1024; 
  static const List<String> allowedFileTypes = ['pdf', 'png', 'jpg', 'jpeg'];

  // ========== DEBUG INFO ==========
  static void printConfig() {
    print('🔧 API Configuration:');
    print('📍 Environment: ${isDevelopment ? "Development" : "Production"}');
    print('📱 Device Type: ${currentDevice.name}');
    print('🌐 Base URL: $baseUrl');
    print('🔗 OCR Endpoint: $fullOcrUrl');
  }
}

// ========== DEVICE TYPE ENUM ==========
enum DeviceType {
  androidEmulator,
  iosSimulator,
  realDevice,
}
