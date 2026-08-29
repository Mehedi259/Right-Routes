import 'package:dio/dio.dart';
import '../../domain/entities/auth_result.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<AuthResult> checkDeviceInfo(Map<String, dynamic> deviceInfo) async {
    return _handleRequest(() => remoteDataSource.checkDeviceInfo(deviceInfo));
  }

  @override
  Future<AuthResult> sendDeviceInfo(Map<String, dynamic> deviceInfo) async {
    return _handleRequest(() => remoteDataSource.sendDeviceInfo(deviceInfo));
  }

  @override
  Future<AuthResult> continueWithEmail(String email) async {
    return _handleRequest(() => remoteDataSource.continueWithEmail(email));
  }

  @override
  Future<AuthResult> createPassword(String email, String password) async {
    return _handleRequest(() => remoteDataSource.createPassword(email, password));
  }

  @override
  Future<AuthResult> verifyOtp({
    required String email, 
    required String otpCode, 
    required String purpose,
  }) async {
    return _handleRequest(() => remoteDataSource.verifyOtp(email, otpCode, purpose));
  }

  @override
  Future<AuthResult> resendOtp({
    required String email, 
    required String purpose,
  }) async {
    return _handleRequest(() => remoteDataSource.resendOtp(email, purpose));
  }

  @override
  Future<AuthResult> login(String email, String password) async {
    return _handleRequest(() => remoteDataSource.login(email, password));
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CENTRALIZED ERROR HANDLING & MAPPING
  // ═══════════════════════════════════════════════════════════════════════════
  Future<AuthResult> _handleRequest(Future<Response> Function() request) async {
    try {
      final response = await request();
      final data = response.data;

      return AuthResult(
        success: data['success'] ?? true,
        message: _extractMessage(data),
        nextStep: data['next_step'],
        isRegistered: data['is_registered'],
        data: data,
      );
    } on DioException catch (e) {
      String errorMessage = "An unexpected network error occurred.";
      
      if (e.response != null && e.response?.data != null) {
        final errorData = e.response!.data;
        errorMessage = _extractMessage(errorData) ?? e.message ?? errorMessage;
      }

      return AuthResult(
        success: false,
        message: errorMessage,
        data: e.response?.data,
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: "An internal error occurred: $e",
      );
    }
  }

  /// Helper to extract dynamic error messages or success details from the backend JSON
  String? _extractMessage(dynamic data) {
    if (data is Map) {
      if (data.containsKey('detail')) {
        final detail = data['detail'];
        if (detail is Map) {
          // Extracts the first available error message if detail is an object
          return detail.values.first.toString();
        }
        return detail.toString();
      }
      return data['message'];
    }
    return null;
  }
}
