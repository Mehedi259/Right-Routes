// ═══════════════════════════════════════════════════════════════════════════
// route_permit_model.dart
// Models for GET /navigation/route/{routeId}/permit/ response
// ═══════════════════════════════════════════════════════════════════════════

class RoutePermitResponse {
  final bool success;
  final RoutePermitData data;

  RoutePermitResponse({required this.success, required this.data});

  factory RoutePermitResponse.fromJson(Map<String, dynamic> json) {
    return RoutePermitResponse(
      success: json['success'] as bool? ?? false,
      data: RoutePermitData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class RoutePermitData {
  final String routeName;
  final String routeDescription;
  final String routeStatus;
  final bool routeIsCompleted;
  final bool isPermit;
  final List<PermitItem> permits;

  RoutePermitData({
    required this.routeName,
    required this.routeDescription,
    required this.routeStatus,
    required this.routeIsCompleted,
    required this.isPermit,
    required this.permits,
  });

  factory RoutePermitData.fromJson(Map<String, dynamic> json) {
    final permitList = (json['permit'] as List<dynamic>? ?? [])
        .map((e) => PermitItem.fromJson(e as Map<String, dynamic>))
        .toList();

    return RoutePermitData(
      routeName: json['route_name']?.toString() ?? '',
      routeDescription: json['route_description']?.toString() ?? '',
      routeStatus: json['route_status']?.toString() ?? '',
      routeIsCompleted: json['route_is_completed'] as bool? ?? false,
      isPermit: json['is_permit'] as bool? ?? false,
      permits: permitList,
    );
  }
}

class PermitItem {
  final int id;
  final int route;
  final int order;
  final String? name;
  final String startLocationName;
  final double startLatitude;
  final double startLongitude;
  final String endLocationName;
  final double endLatitude;
  final double endLongitude;
  final String? permitFile;
  final double totalDistance;
  final List<WaypointItem> waypoints;

  PermitItem({
    required this.id,
    required this.route,
    required this.order,
    this.name,
    required this.startLocationName,
    required this.startLatitude,
    required this.startLongitude,
    required this.endLocationName,
    required this.endLatitude,
    required this.endLongitude,
    this.permitFile,
    required this.totalDistance,
    required this.waypoints,
  });

  /// Display-friendly title: uses [name] if set, otherwise "Permit #[order]"
  String get displayTitle => (name != null && name!.isNotEmpty)
      ? name!
      : 'PERMIT #$order';

  factory PermitItem.fromJson(Map<String, dynamic> json) {
    final waypointList = (json['waypoints'] as List<dynamic>? ?? [])
        .map((e) => WaypointItem.fromJson(e as Map<String, dynamic>))
        .toList();

    return PermitItem(
      id: (json['id'] as num).toInt(),
      route: (json['route'] as num).toInt(),
      order: (json['order'] as num? ?? 0).toInt(),
      name: json['name']?.toString(),
      startLocationName: json['start_location_name']?.toString() ?? '',
      startLatitude: _parseDouble(json['start_latitude']),
      startLongitude: _parseDouble(json['start_longitude']),
      endLocationName: json['end_location_name']?.toString() ?? '',
      endLatitude: _parseDouble(json['end_latitude']),
      endLongitude: _parseDouble(json['end_longitude']),
      permitFile: json['permit_file']?.toString(),
      totalDistance: _parseDouble(json['total_distance']),
      waypoints: waypointList,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }
}

class WaypointItem {
  final int id;
  final int order;
  final String name;
  final double latitude;
  final double longitude;
  final String? description;
  final String icon;
  final String createdAt;
  final int permit;

  WaypointItem({
    required this.id,
    required this.order,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.description,
    required this.icon,
    required this.createdAt,
    required this.permit,
  });

  factory WaypointItem.fromJson(Map<String, dynamic> json) {
    return WaypointItem(
      id: (json['id'] as num).toInt(),
      order: (json['order'] as num? ?? 0).toInt(),
      name: json['name']?.toString() ?? 'Waypoint',
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      description: json['description']?.toString(),
      icon: json['icon']?.toString() ?? '📍',
      createdAt: json['created_at']?.toString() ?? '',
      permit: (json['permit'] as num? ?? 0).toInt(),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }
}
