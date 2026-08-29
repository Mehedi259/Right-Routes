import 'package:flutter_test/flutter_test.dart';
import 'package:right_routes/utils/distance_calculator.dart';

void main() {
  group('DistanceCalculator Tests', () {
    test('calculates distance between NYC and LA correctly', () {
      // New York City: 40.7128° N, 74.0060° W
      // Los Angeles: 34.0522° N, 118.2437° W
      // Expected distance: approximately 2451 miles

      double distance = DistanceCalculator.calculateDistance(
          40.7128,
          -74.0060, // NYC
          34.0522,
          -118.2437 // LA
          );

      // Allow 50 miles margin of error for straight-line distance
      expect(distance, closeTo(2451, 50));
    });

    test('calculates distance between Des Moines and Chicago correctly', () {
      // Des Moines: 41.5868° N, 93.6250° W
      // Chicago: 41.8781° N, 87.6298° W
      // Expected distance: approximately 330 miles

      double distance = DistanceCalculator.calculateDistance(
          41.5868,
          -93.6250, // Des Moines
          41.8781,
          -87.6298 // Chicago
          );

      // Allow 20 miles margin of error
      expect(distance, closeTo(330, 20));
    });

    test('returns zero distance for same location', () {
      double distance = DistanceCalculator.calculateDistance(
          41.5868,
          -93.6250, // Des Moines
          41.5868,
          -93.6250 // Des Moines (same)
          );

      expect(distance, closeTo(0, 0.1));
    });

    test('calculates distance in kilometers when specified', () {
      // NYC to LA in kilometers: approximately 3944 km

      double distance = DistanceCalculator.calculateDistance(
          40.7128,
          -74.0060, // NYC
          34.0522,
          -118.2437, // LA
          unit: 'km');

      expect(distance, closeTo(3944, 80));
    });

    test('handles antipodal points correctly', () {
      // Test with points on opposite sides of Earth
      // Should be approximately half Earth's circumference

      double distance = DistanceCalculator.calculateDistance(
          0,
          0, // Equator, Prime Meridian
          0,
          180 // Equator, opposite side
          );

      // Half of Earth's circumference in miles: approximately 12,450 miles
      expect(distance, closeTo(12450, 100));
    });

    test('calculateRouteDistance returns 0 for empty list', () {
      double distance = DistanceCalculator.calculateRouteDistance([]);
      expect(distance, 0.0);
    });

    test('calculateRouteDistance returns 0 for single waypoint', () {
      double distance = DistanceCalculator.calculateRouteDistance([
        [41.5868, -93.6250] // Des Moines
      ]);
      expect(distance, 0.0);
    });

    test('calculateRouteDistance calculates total for two waypoints', () {
      double distance = DistanceCalculator.calculateRouteDistance([
        [41.5868, -93.6250], // Des Moines
        [41.8781, -87.6298] // Chicago
      ]);

      // Should be approximately 330 miles
      expect(distance, closeTo(330, 20));
    });

    test('calculateRouteDistance calculates total for multiple waypoints', () {
      // Route: NYC -> Chicago -> LA
      double distance = DistanceCalculator.calculateRouteDistance([
        [40.7128, -74.0060], // NYC
        [41.8781, -87.6298], // Chicago
        [34.0522, -118.2437] // LA
      ]);

      // NYC to Chicago: ~790 miles
      // Chicago to LA: ~2015 miles
      // Total: ~2805 miles
      expect(distance, closeTo(2805, 100));
    });

    test('calculateRouteDistance works with kilometers', () {
      double distance = DistanceCalculator.calculateRouteDistance([
        [40.7128, -74.0060], // NYC
        [41.8781, -87.6298], // Chicago
        [34.0522, -118.2437] // LA
      ], unit: 'km');

      // Total in km: approximately 4515 km
      expect(distance, closeTo(4515, 160));
    });

    test('handles negative coordinates correctly', () {
      // Test with southern and western hemispheres
      double distance = DistanceCalculator.calculateDistance(
          -33.8688,
          151.2093, // Sydney, Australia
          -37.8136,
          144.9631 // Melbourne, Australia
          );

      // Sydney to Melbourne: approximately 440 miles
      expect(distance, closeTo(440, 30));
    });

    test('handles coordinates near poles', () {
      // Test with high latitude coordinates
      double distance = DistanceCalculator.calculateDistance(
          89.0,
          0.0, // Near North Pole
          89.0,
          180.0 // Near North Pole, opposite side
          );

      // Should be a small distance due to high latitude
      expect(distance, lessThan(200));
    });
  });
}
