// ═══════════════════════════════════════════════════════════════════════════
// route_permit_service.dart
// Handles: GET /navigation/route/{routeId}/permit/
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:right_routes/core/constants/services/api_client.dart';
import 'package:right_routes/models/drive_route_permit_model.dart';
import 'package:right_routes/core/constants/api_config/home_api_constant/home_api_constant.dart';

class RoutePermitService {
  /// Fetches all permits for a given [routeId].
  ///
  /// Returns [RoutePermitResponse] on success, throws on network/parse failure.
  static Future<RoutePermitResponse> fetchPermitsForRoute(
      String routeId) async {
    final url = Uri.parse(
      '${HomeApiConstant.baseUrl}/navigation/route/$routeId/permit/',
    );

    debugPrint('🌐 [RoutePermitService] GET → $url');

    final response = await ApiClient.get(url, headers: {
      'Content-Type': 'application/json',
    }).timeout(const Duration(seconds: 30));

    debugPrint('✅ [RoutePermitService] Status: ${response.statusCode}');
    debugPrint('📄 [RoutePermitService] Data: ${response.data}');

    if (response.statusCode == 200) {
      final json = response.data is Map ? response.data as Map<String, dynamic> : <String, dynamic>{};
      return RoutePermitResponse.fromJson(json);
    } else {
      throw Exception(
        'RoutePermitService: HTTP ${response.statusCode} — ${response.data}',
      );
    }
  }

  /// Fetches all permits for [routeId] then returns the single [PermitItem]
  /// matching [permitId]. Returns null if not found.
  static Future<PermitItem?> fetchSinglePermit(
    String routeId,
    String permitId,
  ) async {
    final resp = await fetchPermitsForRoute(routeId);
    final permitIdInt = int.tryParse(permitId);
    if (permitIdInt == null) return null;

    try {
      return resp.data.permits.firstWhere((p) => p.id == permitIdInt);
    } catch (_) {
      return null;
    }
  }

  /// Starts driving for a route.
  /// POST /navigation/route/{routeId}/permit/drive-start/
  static Future<bool> startDrive(String routeId) async {
    final url = Uri.parse(
      '${HomeApiConstant.baseUrl}/route/$routeId/drive-start/',
    );

    debugPrint('🌐 [RoutePermitService] POST → $url');

    try {
      final response = await ApiClient.post(url, body: {}, headers: {
        'Content-Type': 'application/json',
      }).timeout(const Duration(seconds: 15));

      debugPrint(
          '✅ [RoutePermitService] drive-start Status: ${response.statusCode}');
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('❌ [RoutePermitService] drive-start error: $e');
      return false;
    }
  }

  /// Stops driving for a route.
  /// POST /navigation/route/{routeId}/permit/drive-stop/
  static Future<bool> stopDrive(String routeId) async {
    final url = Uri.parse(
      '${HomeApiConstant.baseUrl}/route/$routeId/drive-stop/',
    );

    debugPrint('🌐 [RoutePermitService] POST → $url');

    try {
      final response = await ApiClient.post(url, body: {}, headers: {
        'Content-Type': 'application/json',
      }).timeout(const Duration(seconds: 15));

      debugPrint(
          '✅ [RoutePermitService] drive-stop Status: ${response.statusCode}');
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('❌ [RoutePermitService] drive-stop error: $e');
      return false;
    }
  }

  /// Cancels driving for a route.
  /// POST /route/{routeId}/drive-cancel/
  static Future<bool> cancelDrive(String routeId) async {
    final url = Uri.parse(
      '${HomeApiConstant.baseUrl}/route/$routeId/drive-cancel/',
    );

    debugPrint('🌐 [RoutePermitService] POST → $url');

    try {
      final response = await ApiClient.post(url, body: {}, headers: {
        'Content-Type': 'application/json',
      }).timeout(const Duration(seconds: 15));

      debugPrint(
          '✅ [RoutePermitService] drive-cancel Status: ${response.statusCode}');
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('❌ [RoutePermitService] drive-cancel error: $e');
      return false;
    }
  }

  /// Deletes a permit for a given [routeId] and [permitId].
  /// DELETE /navigation/route/{routeId}/permit/{permitId}/
  static Future<bool> deletePermit(String routeId, String permitId) async {
    final url = Uri.parse(
      '${HomeApiConstant.baseUrl}/navigation/route/$routeId/permit/$permitId/',
    );

    debugPrint('🌐 [RoutePermitService] DELETE → $url');

    try {
      final response = await ApiClient.delete(url, headers: {
        'Content-Type': 'application/json',
      }).timeout(const Duration(seconds: 15));

      debugPrint('✅ [RoutePermitService] deletePermit Status: ${response.statusCode}');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('❌ [RoutePermitService] deletePermit error: $e');
      return false;
    }
  }
}
