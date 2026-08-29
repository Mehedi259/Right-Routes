import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OfflineRouteService extends GetxService {
  static const String _offlineRoutesKey = 'offline_saved_routes';

  // Format of stored route:
  // {
  //   "routeId": "123",
  //   "routeName": "Test Route",
  //   "downloadDate": 1700000000000,
  //   "waypoints": [{"lat": 1.0, "lng": 2.0}, ...]
  // }

  /// Save a route for offline access
  static Future<bool> saveOfflineRoute({
    required String routeId,
    required String routeName,
    required List<LatLng> waypoints,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get existing routes
      List<String> existingRoutesStr = prefs.getStringList(_offlineRoutesKey) ?? [];
      List<Map<String, dynamic>> existingRoutes = existingRoutesStr
          .map((str) => jsonDecode(str) as Map<String, dynamic>)
          .toList();

      // Check if already exists, remove it to overwrite
      existingRoutes.removeWhere((route) => route['routeId'] == routeId);

      // Convert waypoints to JSON-friendly format
      List<Map<String, double>> waypointsJson = waypoints.map((wp) => {
        'lat': wp.latitude,
        'lng': wp.longitude,
      }).toList();

      // Create new route map
      Map<String, dynamic> newRoute = {
        'routeId': routeId,
        'routeName': routeName.isEmpty ? 'Saved Route' : routeName,
        'downloadDate': DateTime.now().millisecondsSinceEpoch,
        'waypoints': waypointsJson,
      };

      existingRoutes.add(newRoute);

      // Save back to SharedPreferences
      List<String> updatedRoutesStr = existingRoutes.map((r) => jsonEncode(r)).toList();
      await prefs.setStringList(_offlineRoutesKey, updatedRoutesStr);
      
      debugPrint('✅ [OfflineRouteService] Saved route $routeId successfully.');
      return true;
    } catch (e) {
      debugPrint('❌ [OfflineRouteService] Failed to save route: $e');
      return false;
    }
  }

  /// Get all saved offline routes
  static Future<List<Map<String, dynamic>>> getOfflineRoutes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> existingRoutesStr = prefs.getStringList(_offlineRoutesKey) ?? [];
      
      List<Map<String, dynamic>> routes = existingRoutesStr
          .map((str) => jsonDecode(str) as Map<String, dynamic>)
          .toList();
          
      // Sort by newest first
      routes.sort((a, b) => (b['downloadDate'] as int).compareTo(a['downloadDate'] as int));
      
      return routes;
    } catch (e) {
      debugPrint('❌ [OfflineRouteService] Failed to get offline routes: $e');
      return [];
    }
  }

  /// Delete a specific offline route
  static Future<bool> deleteOfflineRoute(String routeId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> existingRoutesStr = prefs.getStringList(_offlineRoutesKey) ?? [];
      
      List<Map<String, dynamic>> existingRoutes = existingRoutesStr
          .map((str) => jsonDecode(str) as Map<String, dynamic>)
          .toList();
          
      existingRoutes.removeWhere((route) => route['routeId'] == routeId);
      
      List<String> updatedRoutesStr = existingRoutes.map((r) => jsonEncode(r)).toList();
      await prefs.setStringList(_offlineRoutesKey, updatedRoutesStr);
      
      debugPrint('✅ [OfflineRouteService] Deleted route $routeId successfully.');
      return true;
    } catch (e) {
      debugPrint('❌ [OfflineRouteService] Failed to delete offline route: $e');
      return false;
    }
  }
}
