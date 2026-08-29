import 'package:flutter_test/flutter_test.dart';
import 'package:right_routes/models/waypoint.dart';

void main() {
  group('Waypoint Model Tests', () {
    test('creates waypoint with all properties', () {
      final waypoint = Waypoint(
        id: '1',
        address: 'Des Moines, Iowa',
        latitude: 41.5868,
        longitude: -93.6250,
        index: 0,
      );

      expect(waypoint.id, '1');
      expect(waypoint.address, 'Des Moines, Iowa');
      expect(waypoint.latitude, 41.5868);
      expect(waypoint.longitude, -93.6250);
      expect(waypoint.index, 0);
    });

    test('hasValidCoordinates returns true when coordinates are present', () {
      final waypoint = Waypoint(
        id: '1',
        address: 'Des Moines, Iowa',
        latitude: 41.5868,
        longitude: -93.6250,
        index: 0,
      );

      expect(waypoint.hasValidCoordinates, isTrue);
    });

    test('hasValidCoordinates returns false when latitude is null', () {
      final waypoint = Waypoint(
        id: '1',
        address: 'Des Moines, Iowa',
        longitude: -93.6250,
        index: 0,
      );

      expect(waypoint.hasValidCoordinates, isFalse);
    });

    test('hasValidCoordinates returns false when longitude is null', () {
      final waypoint = Waypoint(
        id: '1',
        address: 'Des Moines, Iowa',
        latitude: 41.5868,
        index: 0,
      );

      expect(waypoint.hasValidCoordinates, isFalse);
    });

    test('hasValidCoordinates returns false when both coordinates are null',
        () {
      final waypoint = Waypoint(
        id: '1',
        address: 'Des Moines, Iowa',
        index: 0,
      );

      expect(waypoint.hasValidCoordinates, isFalse);
    });

    test('toJson converts waypoint to map correctly', () {
      final waypoint = Waypoint(
        id: '1',
        address: 'Des Moines, Iowa',
        latitude: 41.5868,
        longitude: -93.6250,
        index: 0,
      );

      final json = waypoint.toJson();

      expect(json['location'], 'Des Moines, Iowa');
      expect(json['lat'], 41.5868);
      expect(json['lng'], -93.6250);
      expect(json['index'], 0);
    });

    test('toJson handles null coordinates', () {
      final waypoint = Waypoint(
        id: '1',
        address: 'Des Moines, Iowa',
        index: 0,
      );

      final json = waypoint.toJson();

      expect(json['location'], 'Des Moines, Iowa');
      expect(json['lat'], isNull);
      expect(json['lng'], isNull);
      expect(json['index'], 0);
    });

    test('fromJson creates waypoint from map with location key', () {
      final json = {
        'id': '1',
        'location': 'Des Moines, Iowa',
        'lat': 41.5868,
        'lng': -93.6250,
        'index': 0,
      };

      final waypoint = Waypoint.fromJson(json);

      expect(waypoint.id, '1');
      expect(waypoint.address, 'Des Moines, Iowa');
      expect(waypoint.latitude, 41.5868);
      expect(waypoint.longitude, -93.6250);
      expect(waypoint.index, 0);
    });

    test('fromJson creates waypoint from map with address key', () {
      final json = {
        'address': 'Des Moines, Iowa',
        'lat': 41.5868,
        'lng': -93.6250,
        'index': 0,
      };

      final waypoint = Waypoint.fromJson(json);

      expect(waypoint.id, '');
      expect(waypoint.address, 'Des Moines, Iowa');
      expect(waypoint.latitude, 41.5868);
      expect(waypoint.longitude, -93.6250);
      expect(waypoint.index, 0);
    });

    test('fromJson handles missing optional fields', () {
      final json = {
        'location': 'Des Moines, Iowa',
      };

      final waypoint = Waypoint.fromJson(json);

      expect(waypoint.id, '');
      expect(waypoint.address, 'Des Moines, Iowa');
      expect(waypoint.latitude, isNull);
      expect(waypoint.longitude, isNull);
      expect(waypoint.index, 0);
    });

    test('fromJson handles integer coordinates by converting to double', () {
      final json = {
        'location': 'Des Moines, Iowa',
        'lat': 41,
        'lng': -93,
        'index': 0,
      };

      final waypoint = Waypoint.fromJson(json);

      expect(waypoint.latitude, 41.0);
      expect(waypoint.longitude, -93.0);
    });

    test('equality operator works correctly', () {
      final waypoint1 = Waypoint(
        id: '1',
        address: 'Des Moines, Iowa',
        latitude: 41.5868,
        longitude: -93.6250,
        index: 0,
      );

      final waypoint2 = Waypoint(
        id: '1',
        address: 'Des Moines, Iowa',
        latitude: 41.5868,
        longitude: -93.6250,
        index: 0,
      );

      expect(waypoint1, equals(waypoint2));
    });

    test('equality operator returns false for different waypoints', () {
      final waypoint1 = Waypoint(
        id: '1',
        address: 'Des Moines, Iowa',
        latitude: 41.5868,
        longitude: -93.6250,
        index: 0,
      );

      final waypoint2 = Waypoint(
        id: '2',
        address: 'Chicago, Illinois',
        latitude: 41.8781,
        longitude: -87.6298,
        index: 1,
      );

      expect(waypoint1, isNot(equals(waypoint2)));
    });
  });
}
