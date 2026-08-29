import 'package:right_routes/features/auth/domain/entities/auth_result.dart';

// device

abstract class AuthRepository {
  Future<AuthResult> checkDeviceInfo(Map<String, dynamic> deviceInfo);
  Future<AuthResult> sendDeviceInfo(Map<String, dynamic> deviceInfo);
  
  Future<AuthResult> continueWithEmail(String email);
  
  Future<AuthResult> createPassword(String email, String password);
  
  Future<AuthResult> verifyOtp({
    required String email, 
    required String otpCode, 
    required String purpose,
  });
  
  Future<AuthResult> resendOtp({
    required String email, 
    required String purpose,
  });
  
  Future<AuthResult> login(String email, String password);
}
