import 'dart:math';

/// Utility class for calculating distances between geographic coordinates
///
/// Uses the Haversine formula to calculate great-circle distances between
/// two points on a sphere given their longitudes and latitudes.
class DistanceCalculator {
  /// Earth's radius in miles
  static const double earthRadiusMiles = 3958.8;

  /// Earth's radius in kilometers
  static const double earthRadiusKm = 6371.0;

  /// Calculates the distance between two geographic coordinates using the Haversine formula
  ///
  /// Parameters:
  /// - [lat1]: Latitude of the first point in degrees
  /// - [lon1]: Longitude of the first point in degrees
  /// - [lat2]: Latitude of the second point in degrees
  /// - [lon2]: Longitude of the second point in degrees
  /// - [unit]: Unit of measurement ('miles' or 'km'), defaults to 'miles'
  ///
  /// Returns the distance in the specified unit
  ///
  /// Example:
  /// ```dart
  /// double distance = DistanceCalculator.calculateDistance(
  ///   40.7128, -74.0060,  // New York City
  ///   34.0522, -118.2437  // Los Angeles
  /// );
  /// print('Distance: $distance miles');
  /// ```
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2, {
    String unit = 'miles',
  }) {
    // Convert degrees to radians
    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);

    double lat1Rad = _toRadians(lat1);
    double lat2Rad = _toRadians(lat2);

    // Haversine formula
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1Rad) * cos(lat2Rad) * sin(dLon / 2) * sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    // Calculate distance
    double radius = unit == 'km' ? earthRadiusKm : earthRadiusMiles;
    return radius * c;
  }

  /// Converts degrees to radians
  static double _toRadians(double degrees) => degrees * pi / 180;

  /// Calculates the total distance for a route with multiple waypoints
  ///
  /// Parameters:
  /// - [coordinates]: List of coordinate pairs [latitude, longitude]
  /// - [unit]: Unit of measurement ('miles' or 'km'), defaults to 'miles'
  ///
  /// Returns the total distance in the specified unit
  ///
  /// Example:
  /// ```dart
  /// List<List<double>> route = [
  ///   [40.7128, -74.0060],  // NYC
  ///   [41.8781, -87.6298],  // Chicago
  ///   [34.0522, -118.2437]  // LA
  /// ];
  /// double totalDistance = DistanceCalculator.calculateRouteDistance(route);
  /// ```
  static double calculateRouteDistance(
    List<List<double>> coordinates, {
    String unit = 'miles',
  }) {
    if (coordinates.length < 2) {
      return 0.0;
    }

    double totalDistance = 0.0;

    for (int i = 0; i < coordinates.length - 1; i++) {
      double lat1 = coordinates[i][0];
      double lon1 = coordinates[i][1];
      double lat2 = coordinates[i + 1][0];
      double lon2 = coordinates[i + 1][1];

      totalDistance += calculateDistance(lat1, lon1, lat2, lon2, unit: unit);
    }

    return totalDistance;
  }
}
