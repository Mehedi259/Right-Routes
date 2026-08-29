/// Waypoint model representing a location point along a route
///
/// A waypoint contains an address, optional coordinates, and an index
/// indicating its position in the route sequence.
class Waypoint {
  /// Unique identifier for the waypoint
  final String id;

  /// Human-readable address or location description
  String address;

  /// Latitude coordinate (WGS84)
  double? latitude;

  /// Longitude coordinate (WGS84)
  double? longitude;

  /// Position index in the route sequence (0-based)
  int index;

  Waypoint({
    required this.id,
    required this.address,
    this.latitude,
    this.longitude,
    required this.index,
  });

  /// Returns true if the waypoint has valid latitude and longitude coordinates
  bool get hasValidCoordinates => latitude != null && longitude != null;

  /// Converts the waypoint to a JSON map
  ///
  /// Returns a map with keys: location, lat, lng, index
  Map<String, dynamic> toJson() => {
        'location': address,
        'lat': latitude,
        'lng': longitude,
        'index': index,
      };

  /// Creates a waypoint from a JSON map
  ///
  /// Expects keys: location (or address), lat, lng, index
  /// The id field is generated if not provided
  factory Waypoint.fromJson(Map<String, dynamic> json) => Waypoint(
        id: json['id'] ?? '',
        address: json['location'] ?? json['address'] ?? '',
        latitude: json['lat']?.toDouble(),
        longitude: json['lng']?.toDouble(),
        index: json['index'] ?? 0,
      );

  @override
  String toString() =>
      'Waypoint(id: $id, address: $address, lat: $latitude, lng: $longitude, index: $index)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Waypoint &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          address == other.address &&
          latitude == other.latitude &&
          longitude == other.longitude &&
          index == other.index;

  @override
  int get hashCode =>
      id.hashCode ^
      address.hashCode ^
      latitude.hashCode ^
      longitude.hashCode ^
      index.hashCode;
}
