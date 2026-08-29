/// RouteData model for transferring route information between screens
///
/// This model encapsulates all route information needed for navigation,
/// confirmation, and driving screens.
class RouteData {
  /// Name of the route
  final String routeName;

  /// Permit type or group label (e.g., "Permit 1")
  final String permitType;

  /// List of waypoint addresses in sequence
  final List<String> routeSegments;

  /// Address of the first waypoint
  final String startLocation;

  /// Address of the last waypoint
  final String endLocation;

  /// List of waypoints with coordinates (each as a map with location, lat, lng, index)
  final List<Map<String, dynamic>> routeWithCoordinates;

  /// Optional structured step data for turn-by-turn navigation
  final List<Map<String, dynamic>>? routeSteps;

  RouteData({
    required this.routeName,
    required this.permitType,
    required this.routeSegments,
    required this.startLocation,
    required this.endLocation,
    required this.routeWithCoordinates,
    this.routeSteps,
  });

  /// Converts the route data to a JSON map for navigation arguments
  Map<String, dynamic> toJson() => {
        'routeName': routeName,
        'permitType': permitType,
        'routeSegments': routeSegments,
        'startLocation': startLocation,
        'endLocation': endLocation,
        'routeWithCoordinates': routeWithCoordinates,
        'routeSteps': routeSteps,
      };

  /// Creates route data from a JSON map
  factory RouteData.fromJson(Map<String, dynamic> json) => RouteData(
        routeName: json['routeName'] ?? '',
        permitType: json['permitType'] ?? 'Permit 1',
        routeSegments: List<String>.from(json['routeSegments'] ?? []),
        startLocation: json['startLocation'] ?? '',
        endLocation: json['endLocation'] ?? '',
        routeWithCoordinates: List<Map<String, dynamic>>.from(
          json['routeWithCoordinates'] ?? [],
        ),
        routeSteps: json['routeSteps'] != null
            ? List<Map<String, dynamic>>.from(json['routeSteps'])
            : null,
      );

  @override
  String toString() =>
      'RouteData(routeName: $routeName, permitType: $permitType, '
      'segments: ${routeSegments.length}, start: $startLocation, end: $endLocation)';
}
