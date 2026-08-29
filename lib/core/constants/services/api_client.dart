import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import 'auth_service.dart';
import '../api_config/api_config.dart';
import '../../../core/routes/all_routes.dart';

/// ═══════════════════════════════════════════════════════════
/// Central API Client with Token Interception & Refresh Logic
/// ═══════════════════════════════════════════════════════════
class ApiClient {
  static final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
    // Prevent Dio from throwing exceptions for status codes < 500,
    // so we can manually parse API error responses (e.g., 400, 422).
    validateStatus: (status) => status != null && status < 500,
  ));

  static bool _isRefreshing = false;

  /// ═══════════════════════════════════════════════════════════
  /// POST Request
  /// ═══════════════════════════════════════════════════════════
  static Future<Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    bool requireAuth = true,
  }) async {
    return _request(
      (options) => _dio.postUri(
        url,
        data: body,
        options: options,
      ),
      requireAuth: requireAuth,
      customHeaders: headers,
    );
  }

  /// ═══════════════════════════════════════════════════════════
  /// PATCH Request
  /// ═══════════════════════════════════════════════════════════
  static Future<Response> patch(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    bool requireAuth = true,
  }) async {
    return _request(
      (options) => _dio.patchUri(
        url,
        data: body,
        options: options,
      ),
      requireAuth: requireAuth,
      customHeaders: headers,
    );
  }

  /// ═══════════════════════════════════════════════════════════
  /// DELETE Request
  /// ═══════════════════════════════════════════════════════════
  static Future<Response> delete(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    bool requireAuth = true,
  }) async {
    return _request(
      (options) => _dio.deleteUri(
        url,
        data: body,
        options: options,
      ),
      requireAuth: requireAuth,
      customHeaders: headers,
    );
  }

  /// ═══════════════════════════════════════════════════════════
  /// GET Request
  /// ═══════════════════════════════════════════════════════════
  static Future<Response> get(
    Uri url, {
    Map<String, String>? headers,
    bool requireAuth = true,
  }) async {
    return _request(
      (options) => _dio.getUri(
        url,
        options: options,
      ),
      requireAuth: requireAuth,
      customHeaders: headers,
    );
  }

  /// ═══════════════════════════════════════════════════════════
  /// MULTIPART Request (for file uploads)
  /// ═══════════════════════════════════════════════════════════
  static Future<Response> sendMultipartRequest(
    Uri url, {
    required FormData data,
    String method = 'POST',
    bool requireAuth = true,
  }) async {
    return _request(
      (options) {
        options.method = method;
        return _dio.requestUri(
          url,
          data: data,
          options: options,
        );
      },
      requireAuth: requireAuth,
    );
  }

  /// Core request wrapper handling auth token injection and refresh retry.
  static Future<Response> _request(
    Future<Response> Function(Options options) requestCall, {
    bool requireAuth = true,
    Map<String, String>? customHeaders,
  }) async {
    try {
      final headers = Map<String, dynamic>.from(customHeaders ?? {});
      if (requireAuth) {
        final token = await AuthService.getAccessToken();
        if (token != null && token.isNotEmpty) {
          headers['Authorization'] = 'Bearer $token';
        }
      }

      final options = Options(headers: headers);
      var response = await requestCall(options);

      // Handle 401 Unauthorized for refresh
      if (requireAuth && response.statusCode == 401) {
        final refreshed = await _refreshToken();
        if (refreshed) {
          // Retry original request with new token
          final token = await AuthService.getAccessToken();
          final retryHeaders = Map<String, dynamic>.from(customHeaders ?? {});
          retryHeaders['Authorization'] = 'Bearer $token';
          return await requestCall(Options(headers: retryHeaders));
        }
      }

      return response;
    } on DioException catch (e) {
      if (requireAuth && e.response?.statusCode == 401) {
        final refreshed = await _refreshToken();
        if (refreshed) {
          final token = await AuthService.getAccessToken();
          final retryHeaders = Map<String, dynamic>.from(customHeaders ?? {});
          retryHeaders['Authorization'] = 'Bearer $token';
          return await requestCall(Options(headers: retryHeaders));
        }
      }

      if (e.response != null) {
        return e.response!;
      }
      rethrow;
    }
  }

  /// ═══════════════════════════════════════════════════════════
  /// Token Refresh Logic
  /// ═══════════════════════════════════════════════════════════
  static Future<bool> _refreshToken() async {
    if (_isRefreshing) return false;

    try {
      _isRefreshing = true;
      print('🔄 Attempting to refresh token...');

      final refreshToken = await AuthService.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        print('❌ No refresh token found. Logging out.');
        _forceLogout();
        return false;
      }

      final formData = FormData.fromMap({'refresh': refreshToken});

      final response = await _dio.post(
        ApiConfig.fullRefreshTokenUrl,
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          final tokenData = data['data'];

          if (tokenData['access'] != null) {
            await AuthService.saveAccessToken(tokenData['access']);
            print('✅ Access token successfully refreshed');
          }
          if (tokenData['refresh'] != null) {
            await AuthService.saveRefreshToken(tokenData['refresh']);
          }

          return true;
        }
      }

      print('❌ Failed to refresh token. Status: ${response.statusCode}');
      _forceLogout();
      return false;

    } catch (e) {
      print('❌ Exception during token refresh: $e');
      _forceLogout();
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  static void _forceLogout() {
    AuthService.logout();
    Get.offAllNamed(AppRoutes.splashScreen); // Redirect to login/splash
    Get.snackbar(
      'Session Expired',
      'Please log in again to continue.',
      snackPosition: SnackPosition.TOP,
    );
  }
}
