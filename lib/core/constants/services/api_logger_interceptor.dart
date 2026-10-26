import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// ═══════════════════════════════════════════════════════════════════
/// Centralized API Logger & Interceptor for Terminal Debugging
/// Prints Request URL, Method, Headers, Query Params, Body, Response,
/// and Errors with clean formatting in the terminal console.
/// ═══════════════════════════════════════════════════════════════════
class ApiLoggerInterceptor extends Interceptor {
  static const String _startTimeKey = 'api_logger_start_time';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_startTimeKey] = DateTime.now().millisecondsSinceEpoch;

    final buffer = StringBuffer();
    buffer.writeln('╔══════════════════════════════════════════════════════════════════════════════');
    buffer.writeln('║ 🚀 [API REQUEST] ${options.method} ${options.uri}');
    buffer.writeln('╠──────────────────────────────────────────────────────────────────────────────');

    // Headers
    if (options.headers.isNotEmpty) {
      buffer.writeln('║ 📋 Headers:');
      options.headers.forEach((key, value) {
        buffer.writeln('║    $key: $value');
      });
    }

    // Query parameters
    if (options.queryParameters.isNotEmpty) {
      buffer.writeln('║ 🔍 Query Parameters:');
      options.queryParameters.forEach((key, value) {
        buffer.writeln('║    $key: $value');
      });
    }

    // Request Body
    if (options.data != null) {
      if (options.data is FormData) {
        final formData = options.data as FormData;
        buffer.writeln('║ 📦 Request Body (FormData Fields):');
        if (formData.fields.isEmpty) {
          buffer.writeln('║    (no text fields)');
        } else {
          for (final field in formData.fields) {
            buffer.writeln('║    ${field.key}: ${field.value}');
          }
        }
        if (formData.files.isNotEmpty) {
          buffer.writeln('║ 📁 Request Files (Attachments):');
          for (final file in formData.files) {
            buffer.writeln(
              '║    ${file.key}: ${file.value.filename ?? "unnamed"} '
              '(${file.value.length} bytes, contentType: ${file.value.contentType})',
            );
          }
        }
      } else {
        buffer.writeln('║ 📦 Request Body:');
        final formattedBody = ApiLogger.formatBody(options.data);
        for (final line in formattedBody.split('\n')) {
          buffer.writeln('║    $line');
        }
      }
    } else {
      buffer.writeln('║ 📦 Request Body: (empty)');
    }

    buffer.writeln('╚══════════════════════════════════════════════════════════════════════════════');
    ApiLogger.printLog(buffer.toString());

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final startTime = response.requestOptions.extra[_startTimeKey] as int?;
    final duration = startTime != null
        ? '${DateTime.now().millisecondsSinceEpoch - startTime}ms'
        : '';

    final statusCode = response.statusCode ?? 0;
    final isSuccess = statusCode >= 200 && statusCode < 300;
    final statusText = isSuccess ? 'SUCCESS' : 'STATUS $statusCode';
    final icon = isSuccess ? '📥' : '⚠️';

    final buffer = StringBuffer();
    buffer.writeln('╔══════════════════════════════════════════════════════════════════════════════');
    buffer.writeln(
      '║ $icon [API RESPONSE - $statusText] [$statusCode ${response.statusMessage ?? ""}] '
      '${duration.isNotEmpty ? "($duration) " : ""}${response.requestOptions.method} ${response.requestOptions.uri}',
    );
    buffer.writeln('╠──────────────────────────────────────────────────────────────────────────────');

    buffer.writeln('║ 📦 Response Body:');
    final formattedBody = ApiLogger.formatBody(response.data);
    for (final line in formattedBody.split('\n')) {
      buffer.writeln('║    $line');
    }

    buffer.writeln('╚══════════════════════════════════════════════════════════════════════════════');
    ApiLogger.printLog(buffer.toString());

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final startTime = err.requestOptions.extra[_startTimeKey] as int?;
    final duration = startTime != null
        ? '${DateTime.now().millisecondsSinceEpoch - startTime}ms'
        : '';

    final statusCode = err.response?.statusCode;
    final statusInfo = statusCode != null ? '[$statusCode] ' : '';

    final buffer = StringBuffer();
    buffer.writeln('╔══════════════════════════════════════════════════════════════════════════════');
    buffer.writeln(
      '║ ❌ [API ERROR] $statusInfo${duration.isNotEmpty ? "($duration) " : ""}'
      '${err.requestOptions.method} ${err.requestOptions.uri}',
    );
    buffer.writeln('╠──────────────────────────────────────────────────────────────────────────────');
    buffer.writeln('║ ⚠️ Error Type: ${err.type}');
    if (err.message != null && err.message!.isNotEmpty) {
      buffer.writeln('║ 💬 Error Message: ${err.message}');
    }

    if (err.response?.data != null) {
      buffer.writeln('║ 📦 Error Response Body:');
      final formattedBody = ApiLogger.formatBody(err.response?.data);
      for (final line in formattedBody.split('\n')) {
        buffer.writeln('║    $line');
      }
    } else {
      buffer.writeln('║ 📦 Error Response Body: (none)');
    }

    buffer.writeln('╚══════════════════════════════════════════════════════════════════════════════');
    ApiLogger.printLog(buffer.toString());

    handler.next(err);
  }
}

/// ═══════════════════════════════════════════════════════════════════
/// Helper class for manual/standalone HTTP logging (e.g., OSRM / http)
/// and safe console printing without truncation.
/// ═══════════════════════════════════════════════════════════════════
class ApiLogger {
  /// Pretty format Map, List, JSON String or any dynamic body
  static String formatBody(dynamic data) {
    if (data == null) return '(empty)';
    if (data is Map || data is List) {
      try {
        const encoder = JsonEncoder.withIndent('  ');
        return encoder.convert(data);
      } catch (_) {
        return data.toString();
      }
    }
    if (data is String) {
      final trimmed = data.trim();
      if ((trimmed.startsWith('{') && trimmed.endsWith('}')) ||
          (trimmed.startsWith('[') && trimmed.endsWith(']'))) {
        try {
          final decoded = jsonDecode(trimmed);
          const encoder = JsonEncoder.withIndent('  ');
          return encoder.convert(decoded);
        } catch (_) {
          return data;
        }
      }
      return data;
    }
    return data.toString();
  }

  /// Print large multiline text safely into terminal/debugPrint
  static void printLog(String text) {
    for (final line in text.split('\n')) {
      if (line.length > 800) {
        for (int i = 0; i < line.length; i += 800) {
          final end = (i + 800 < line.length) ? i + 800 : line.length;
          debugPrint(line.substring(i, end));
        }
      } else {
        debugPrint(line);
      }
    }
  }

  /// Standalone logging helper for `http` package calls (e.g. OSRM)
  static void logHttp({
    required String method,
    required Uri url,
    required int statusCode,
    String? requestBody,
    String? responseBody,
    String? error,
    Duration? duration,
  }) {
    final buffer = StringBuffer();
    final isSuccess = statusCode >= 200 && statusCode < 300;
    final icon = isSuccess ? '🌐 [HTTP CALL]' : '⚠️ [HTTP CALL ERROR]';

    buffer.writeln('╔══════════════════════════════════════════════════════════════════════════════');
    buffer.writeln(
      '║ $icon $method $url '
      '[Status: $statusCode]${duration != null ? " (${duration.inMilliseconds}ms)" : ""}',
    );
    buffer.writeln('╠──────────────────────────────────────────────────────────────────────────────');

    if (requestBody != null && requestBody.isNotEmpty) {
      buffer.writeln('║ 📤 Request Body:');
      for (final line in formatBody(requestBody).split('\n')) {
        buffer.writeln('║    $line');
      }
    }

    if (responseBody != null && responseBody.isNotEmpty) {
      buffer.writeln('║ 📦 Response Body:');
      for (final line in formatBody(responseBody).split('\n')) {
        buffer.writeln('║    $line');
      }
    }

    if (error != null && error.isNotEmpty) {
      buffer.writeln('║ ❌ Error: $error');
    }

    buffer.writeln('╚══════════════════════════════════════════════════════════════════════════════');
    printLog(buffer.toString());
  }
}
