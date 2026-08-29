import 'package:dio/dio.dart';
import '../../../../core/constants/api_config/home_api_constant/home_api_constant.dart';

abstract class AuthRemoteDataSource {
  Future<Response> checkDeviceInfo(Map<String, dynamic> deviceInfo);
  Future<Response> sendDeviceInfo(Map<String, dynamic> deviceInfo);
  Future<Response> continueWithEmail(String email);
  Future<Response> createPassword(String email, String password);
  Future<Response> verifyOtp(String email, String otpCode, String purpose);
  Future<Response> resendOtp(String email, String purpose);
  Future<Response> login(String email, String password);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;
  
  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<Response> checkDeviceInfo(Map<String, dynamic> deviceInfo) async {
    return await dio.get(
      '${HomeApiConstant.baseUrl}/auth/device-info/',
      data: deviceInfo, // Using data in GET request as requested by API
    );
  }

  @override
  Future<Response> sendDeviceInfo(Map<String, dynamic> deviceInfo) async {
    return await dio.post(
      '${HomeApiConstant.baseUrl}/auth/device-info/',
      data: FormData.fromMap(deviceInfo),
    );
  }

  @override
  Future<Response> continueWithEmail(String email) async {
    return await dio.post(
      '${HomeApiConstant.baseUrl}/auth/continue/',
      data: FormData.fromMap({
        'email': email,
      }),
    );
  }

  @override
  Future<Response> createPassword(String email, String password) async {
    return await dio.post(
      '${HomeApiConstant.baseUrl}/auth/create-password/',
      data: FormData.fromMap({
        'email': email,
        'password': password,
      }),
    );
  }

  @override
  Future<Response> verifyOtp(String email, String otpCode, String purpose) async {
    return await dio.post(
      '${HomeApiConstant.baseUrl}/auth/verify-otp/',
      data: FormData.fromMap({
        'email': email,
        'otp_code': otpCode,
        'purpose': purpose,
      }),
    );
  }

  @override
  Future<Response> resendOtp(String email, String purpose) async {
    return await dio.post(
      '${HomeApiConstant.baseUrl}/auth/resend-otp/',
      data: FormData.fromMap({
        'email': email,
        'purpose': purpose,
      }),
    );
  }

  @override
  Future<Response> login(String email, String password) async {
    return await dio.post(
      '${HomeApiConstant.baseUrl}/auth/login/',
      data: FormData.fromMap({
        'email': email,
        'password': password,
      }),
    );
  }
}
