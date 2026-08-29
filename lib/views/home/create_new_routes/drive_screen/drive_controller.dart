import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
import 'dart:convert';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:right_routes/core/constants/services/route_permit_service.dart';
import 'package:right_routes/core/constants/services/offline_route_service.dart';
import 'package:right_routes/utils/map_icon_util.dart';

class DriveController extends GetxController
    with GetSingleTickerProviderStateMixin {
  MapLibreMapController? mapController;

  final RxDouble vehicleLat = 23.8103.obs;
  final RxDouble vehicleLng = 90.4125.obs;
  final RxDouble vehicleBearing = 0.0.obs;
  double _targetBearing = 0.0;

  double? _previousLat;
  double? _previousLng;

  Symbol? _vehicleSymbol;
  Line? _routeLine;

  final RxBool isTracking = true.obs;

  bool _hasRealGPS = false;
  double _metersSinceLastRedraw = 0;
  static const double _redrawEveryMeters = 150;

  late AnimationController _rotationController;
  StreamSubscription<Position>? _positionSubscription;

  List<LatLng> waypointPositions = [];
  String routeId = '';

  Timer? _simulationTimer;
  List<LatLng> _simulatedPath = [];
  bool _isSimulating = false;

  final List<Symbol> _waypointSymbols = [];
  bool _waypointIconsLoaded = false;

  @override
  void onInit() {
    super.onInit();
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _initFromArguments();
    _requestPermission();
    startDriveApi();
  }

  bool _isApiHandled = false;

  @override
  void onClose() {
    _simulationTimer?.cancel();
    _positionSubscription?.cancel();
    _rotationController.dispose();
    if (!_isApiHandled) {
      stopDriveApi();
    }
    super.onClose();
  }

  void _initFromArguments() {
    final args = Get.arguments;
    debugPrint('📋 [DriveController] Received arguments: $args');

    if (args != null && args is Map) {
      if (args['routePoints'] != null) {
        try {
          final rawList = args['routePoints'] as List;
          waypointPositions = rawList.map((e) {
            if (e is LatLng) return e;
            if (e is Map) {
              final lat = (e['latitude'] ?? e['lat'] ?? 0.0) as num;
              final lng = (e['longitude'] ?? e['lng'] ?? 0.0) as num;
              return LatLng(lat.toDouble(), lng.toDouble());
            }
            if (e is List && e.length >= 2) {
              return LatLng((e[0] as num).toDouble(), (e[1] as num).toDouble());
            }
            throw Exception('Invalid point format in routePoints');
          }).toList();
          debugPrint(
              '✅ [DriveController] Loaded ${waypointPositions.length} waypoints');
        } catch (e) {
          debugPrint('❌ [DriveController] Error parsing routePoints: $e');
        }

        if (waypointPositions.isNotEmpty) {
          vehicleLat.value = waypointPositions.first.latitude;
          vehicleLng.value = waypointPositions.first.longitude;
          _previousLat = vehicleLat.value;
          _previousLng = vehicleLng.value;
        }
      }

      if (args['routeId'] != null) {
        routeId = args['routeId'].toString();
      }
    }
  }

  Future<void> startDriveApi() async {
    if (routeId.isEmpty) return;
    try {
      final success = await RoutePermitService.startDrive(routeId);
      if (success && !isClosed) {
        Get.snackbar(
          'Drive Started',
          'Server navigation state started',
          backgroundColor: Colors.green.withValues(alpha: 0.9),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      debugPrint('❌ [DriveController] Error in startDrive API: $e');
    }
  }

  Future<void> stopDriveApi() async {
    if (routeId.isEmpty || _isApiHandled) return;
    _isApiHandled = true;
    try {
      final success = await RoutePermitService.stopDrive(routeId);
      if (success && !isClosed) {
        Get.snackbar(
          'Drive Stopped',
          'Server navigation state stopped',
          backgroundColor: Colors.orange.withValues(alpha: 0.9),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      debugPrint('❌ [DriveController] Error in stopDrive API: $e');
    }
  }

  final RxDouble downloadProgress = 0.0.obs;
  final RxBool isDownloading = false.obs;

  Future<void> downloadOfflineMap() async {
    if (waypointPositions.isEmpty) return;
    if (isDownloading.value) return;

    isDownloading.value = true;
    downloadProgress.value = 0.0;

    Get.snackbar(
      'Downloading Map',
      'Please stay on this screen until the download finishes. This may take a minute...',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.blue.withValues(alpha: 0.9),
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
    );

    try {
      double minLat = waypointPositions[0].latitude;
      double maxLat = waypointPositions[0].latitude;
      double minLng = waypointPositions[0].longitude;
      double maxLng = waypointPositions[0].longitude;

      for (var point in waypointPositions) {
        if (point.latitude < minLat) minLat = point.latitude;
        if (point.latitude > maxLat) maxLat = point.latitude;
        if (point.longitude < minLng) minLng = point.longitude;
        if (point.longitude > maxLng) maxLng = point.longitude;
      }

      final latPadding = (maxLat - minLat) * 0.1;
      final lngPadding = (maxLng - minLng) * 0.1;

      minLat = minLat - (latPadding == 0 ? 0.05 : latPadding);
      maxLat = maxLat + (latPadding == 0 ? 0.05 : latPadding);
      minLng = minLng - (lngPadding == 0 ? 0.05 : lngPadding);
      maxLng = maxLng + (lngPadding == 0 ? 0.05 : lngPadding);

      // Ensure bounds are valid
      minLat = minLat.clamp(-90.0, 90.0);
      maxLat = maxLat.clamp(-90.0, 90.0);
      minLng = minLng.clamp(-180.0, 180.0);
      maxLng = maxLng.clamp(-180.0, 180.0);

      // Dynamically calculate maxZoom based on route size to prevent massive downloads
      final latSpan = (maxLat - minLat).abs();
      final lngSpan = (maxLng - minLng).abs();
      final maxSpan = latSpan > lngSpan ? latSpan : lngSpan;
      
      int dynamicMaxZoom = 14;
      if (maxSpan > 100) {
        dynamicMaxZoom = 3; // Global route (e.g., USA to China). Entire world is 64 tiles.
      } else if (maxSpan > 40) {
        dynamicMaxZoom = 5; // Continental route (e.g., Europe to Asia). 
      } else if (maxSpan > 10) {
        dynamicMaxZoom = 7; // Cross-country (> 1000km). Tiles are ~300km wide.
      } else if (maxSpan > 5) {
        dynamicMaxZoom = 9; // State-wide (> 500km). Tiles are ~75km wide.
      } else if (maxSpan > 2) {
        dynamicMaxZoom = 10; // Inter-city (> 200km). Tiles are ~40km wide.
      } else if (maxSpan > 0.5) {
        dynamicMaxZoom = 12; // City-wide (> 50km). Tiles are ~10km wide.
      }
      
      // Ensure minZoom is always strictly less than or equal to maxZoom to prevent Native crash
      double dynamicMinZoom = dynamicMaxZoom > 4 ? 4.0 : dynamicMaxZoom.toDouble();

      final definition = OfflineRegionDefinition(
        bounds: LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        mapStyleUrl:
            'https://api.maptiler.com/maps/streets-v2/style.json?key=N2YLLvhtmoQzVSf9VfF9',
        minZoom: dynamicMinZoom,
        maxZoom: dynamicMaxZoom.toDouble(),
      );

      final completer = Completer<void>();

      await downloadOfflineRegion(
        definition,
        metadata: {
          'name': 'Drive Route Offline Map',
        },
        onEvent: (status) {
          if (status is InProgress) {
            downloadProgress.value = status.progress / 100.0;
          } else if (status is Success) {
            if (!completer.isCompleted) completer.complete();
          } else if (status is Error) {
            if (!completer.isCompleted) completer.completeError(status.cause);
          }
        },
      );

      await completer.future;

      final String generatedRouteId = routeId.isNotEmpty ? routeId : 'route_${DateTime.now().millisecondsSinceEpoch}';
      await OfflineRouteService.saveOfflineRoute(
        routeId: generatedRouteId,
        routeName: routeId.isNotEmpty ? 'Route $routeId' : 'Saved Route',
        waypoints: waypointPositions,
      );

      isDownloading.value = false;

      Get.snackbar(
        'Download Complete',
        'Offline map has been successfully downloaded.',
        backgroundColor: Colors.green.withValues(alpha: 0.9),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      isDownloading.value = false;
      debugPrint('❌ [DriveController] Error downloading offline map: $e');
      
      String errorMsg = 'Failed to download map: $e';
      if (e.toString().contains('429') || e.toString().contains('RATE_LIMIT')) {
        errorMsg = 'Route is too large to download at once. Please create a shorter route for offline use.';
      }

      Get.snackbar(
        'Error',
        errorMsg,
        backgroundColor: Colors.red.withValues(alpha: 0.9),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 6),
      );
    }
  }

  Future<void> cancelDriveApi() async {
    if (routeId.isEmpty || _isApiHandled) return;
    _isApiHandled = true;
    try {
      final success = await RoutePermitService.cancelDrive(routeId);
      if (success && !isClosed) {
        Get.snackbar(
          'Drive Cancelled',
          'Server navigation state cancelled',
          backgroundColor: Colors.red.withValues(alpha: 0.9),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      debugPrint('❌ [DriveController] Error in cancelDrive API: $e');
    }
  }

  double _calculateBearing(double lat1, double lon1, double lat2, double lon2) {
    final dLon = (lon2 - lon1) * math.pi / 180;
    final y = math.sin(dLon) * math.cos(lat2 * math.pi / 180);
    final x = math.cos(lat1 * math.pi / 180) * math.sin(lat2 * math.pi / 180) -
        math.sin(lat1 * math.pi / 180) *
            math.cos(lat2 * math.pi / 180) *
            math.cos(dLon);
    final bearing = math.atan2(y, x) * 180 / math.pi;
    return (bearing + 360) % 360;
  }

  void _updateBearing(double newBearing) {
    double diff = (newBearing - vehicleBearing.value) % 360;
    if (diff > 180) {
      diff -= 360;
    }
    _targetBearing = vehicleBearing.value + diff;
    try {
      if (_rotationController.status != AnimationStatus.forward) {
        _rotationController.forward(from: 0);
      }
    } catch (e) {
      debugPrint('Rotation animation error: $e');
    }
    vehicleBearing.value = _targetBearing;
  }

  Future<void> _requestPermission() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      await _initializeFromWaypoints();
      _startTracking();
    } else {
      Get.snackbar(
        'Permission Required',
        'Please enable location permission',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      await _initializeFromWaypoints();
    }
  }

  Future<void> _initializeFromWaypoints() async {
    LatLng? startLatLng;
    bool hasRealLocation = false;

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 4),
        ),
      );
      startLatLng = LatLng(position.latitude, position.longitude);
      hasRealLocation = true;
    } catch (e) {
      debugPrint('⚠️ [DriveController] Could not fetch current location: $e');
    }

    if (startLatLng == null && waypointPositions.isNotEmpty) {
      startLatLng = waypointPositions.first;
    }

    if (startLatLng != null) {
      vehicleLat.value = startLatLng.latitude;
      vehicleLng.value = startLatLng.longitude;
      _previousLat = vehicleLat.value;
      _previousLng = vehicleLng.value;
      vehicleBearing.value = 0.0;
      _targetBearing = 0.0;
      _hasRealGPS = hasRealLocation;

      await drawRoute();
      recenter();
      _updateVehicleMarker();
    } else {
      Get.snackbar(
        'Error',
        'No route data or location available',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _startTracking() {
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 2,
      ),
    ).listen((position) {
      if (_isSimulating && _simulatedPath.isNotEmpty) {
        final startDist = Geolocator.distanceBetween(
          _simulatedPath.first.latitude,
          _simulatedPath.first.longitude,
          position.latitude,
          position.longitude,
        );
        if (startDist > 50) {
          _isSimulating = false;
          _simulationTimer?.cancel();
        } else {
          return;
        }
      }

      double newBearing = vehicleBearing.value;
      if (position.heading >= 0) {
        newBearing = position.heading;
      } else if (_previousLat != null && _previousLng != null) {
        double moveDist = Geolocator.distanceBetween(
          _previousLat!,
          _previousLng!,
          position.latitude,
          position.longitude,
        );
        if (moveDist > 3) {
          newBearing = _calculateBearing(
            _previousLat!,
            _previousLng!,
            position.latitude,
            position.longitude,
          );
        }
      }
      _updateBearing(newBearing);

      if (_previousLat != null && _previousLng != null) {
        _metersSinceLastRedraw += Geolocator.distanceBetween(
          _previousLat!,
          _previousLng!,
          position.latitude,
          position.longitude,
        );
      }

      vehicleLat.value = position.latitude;
      vehicleLng.value = position.longitude;
      _previousLat = position.latitude;
      _previousLng = position.longitude;
      _hasRealGPS = true;

      _updateVehicleMarker();

      if (isTracking.value && mapController != null) {
        mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(vehicleLat.value, vehicleLng.value),
              zoom: 14.0,
              tilt: 45.0,
              bearing: vehicleBearing.value,
            ),
          ),
          duration: const Duration(milliseconds: 1000),
        );
      }

      if (_metersSinceLastRedraw >= _redrawEveryMeters) {
        _metersSinceLastRedraw = 0;
        drawRoute();
      }
    });
  }

  void _updateVehicleMarker() async {
    if (mapController == null) return;
    if (!_hasRealGPS) {
      if (_vehicleSymbol != null) {
        try {
          await mapController!.removeSymbol(_vehicleSymbol!);
        } catch (e) {
          debugPrint('Error: $e');
        }
        _vehicleSymbol = null;
      }
      return;
    }

    if (_vehicleSymbol != null) {
      try {
        await mapController!.updateSymbol(
          _vehicleSymbol!,
          SymbolOptions(
            geometry: LatLng(vehicleLat.value, vehicleLng.value),
            iconRotate: vehicleBearing.value,
          ),
        );
      } catch (e) {
        _vehicleSymbol = null;
        await ensureVehicleSymbol();
      }
    } else {
      await ensureVehicleSymbol();
    }
  }

  Future<void> loadWaypointIcon() async {
    if (mapController == null || _waypointIconsLoaded) return;
    try {
      final bytes = await rootBundle.load('assets/icons/Map-Pin-orange.png');
      await mapController!.addImage('wp-pin', bytes.buffer.asUint8List());

      await MapIconUtil.loadStartEndIcons(mapController!);

      _waypointIconsLoaded = true;
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  Future<void> addWaypointMarkers() async {
    if (mapController == null) return;
    try {
      await mapController!.clearSymbols();
      await mapController!.clearCircles();
      _waypointSymbols.clear();
      _vehicleSymbol = null;
    } catch (e) {
      debugPrint('Error: $e');
    }

    for (int i = 0; i < waypointPositions.length; i++) {
      final isStart = i == 0;
      final isEnd =
          i == waypointPositions.length - 1 && waypointPositions.length > 1;

      if (isStart || isEnd) {
        try {
          final sym = await mapController!.addSymbol(SymbolOptions(
            geometry: waypointPositions[i],
            iconImage: isStart ? 'start-icon' : 'end-icon',
            iconSize: 1.0,
            iconAnchor: 'center',
            zIndex: 100,
            draggable: false,
          ));
          _waypointSymbols.add(sym);
        } catch (e) {
          debugPrint('Error: $e');
        }
      } else {
        if (_waypointIconsLoaded) {
          try {
            final sym = await mapController!.addSymbol(SymbolOptions(
              geometry: waypointPositions[i],
              iconImage: 'wp-pin',
              iconSize: 0.45,
              textField: '$i',
              textSize: 10.0,
              textOffset: const Offset(0, 1.2),
              textColor: '#FFFFFF',
              textHaloColor: '#000000',
              textHaloWidth: 1.5,
              textHaloBlur: 0.5,
              zIndex: 1,
              draggable: false,
            ));
            _waypointSymbols.add(sym);
          } catch (e) {
            debugPrint('Error: $e');
          }
        } else {
          try {
            await mapController!.addCircle(CircleOptions(
              geometry: waypointPositions[i],
              circleRadius: 8.0,
              circleColor: '#FF6B35',
              circleStrokeWidth: 2.0,
              circleStrokeColor: '#FFFFFF',
            ));
          } catch (e) {
            debugPrint('Error: $e');
          }
        }
      }
    }
  }

  Future<void> ensureVehicleSymbol() async {
    if (mapController == null || _vehicleSymbol != null || !_hasRealGPS) return;
    try {
      _vehicleSymbol = await mapController!.addSymbol(
        SymbolOptions(
          geometry: LatLng(vehicleLat.value, vehicleLng.value),
          iconImage: 'car-icon',
          iconSize: 0.8,
          iconRotate: vehicleBearing.value,
          iconAnchor: 'center',
        ),
      );
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  void recenter() {
    isTracking.value = true;
    if (mapController != null) {
      mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(vehicleLat.value, vehicleLng.value),
            zoom: 14.0,
            tilt: 45.0,
            bearing: vehicleBearing.value,
          ),
        ),
        duration: const Duration(milliseconds: 1000),
      );
    }
  }

  List<LatLng>? _fullRouteGeometry;
  Line? _passedRouteLine;
  Line? _remainingRouteLine;

  Future<void> drawRoute() async {
    if (mapController == null) return;
    if (waypointPositions.isEmpty) return;

    Future<List<LatLng>?> fetchOSRMRoute(List<LatLng> points) async {
      if (points.length < 2) return null;
      try {
        final coords = points.map((p) => '${p.longitude},${p.latitude}').join(';');
        final res = await http.get(
          Uri.parse('https://router.project-osrm.org/route/v1/driving/$coords?overview=full&geometries=geojson'),
          headers: {'User-Agent': 'RightRoutes/1.0'},
        ).timeout(const Duration(seconds: 15));

        if (res.statusCode == 200) {
          final data = json.decode(res.body);
          if (data['routes']?.isNotEmpty == true) {
            final route = data['routes'][0];
            final coordsList = route['geometry']['coordinates'] as List;
            return coordsList
                .map<LatLng>((c) => LatLng(
                      (c[1] as num).toDouble(),
                      (c[0] as num).toDouble(),
                    ))
                .toList();
          }
        }
      } catch (e) {
        debugPrint('OSRM fetch error: $e');
      }
      return null;
    }

    // 1. Fetch full route only ONCE or if it's missing
    if (_fullRouteGeometry == null) {
      final cleanWaypoints = waypointPositions.where((p) => p.latitude != 0.0 && p.longitude != 0.0).toList();
      
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String cacheKey = 'route_geometry_$routeId';
      
      _fullRouteGeometry = await fetchOSRMRoute(cleanWaypoints);
      
      if (_fullRouteGeometry != null && routeId.isNotEmpty) {
        // Save to cache for offline use
        List<Map<String, double>> cacheData = _fullRouteGeometry!.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList();
        await prefs.setString(cacheKey, json.encode(cacheData));
        debugPrint('✅ Saved route geometry to local cache!');
      } else {
        // Fallback to cache if offline
        if (routeId.isNotEmpty) {
          String? cachedJson = prefs.getString(cacheKey);
          if (cachedJson != null) {
            try {
              List<dynamic> decoded = json.decode(cachedJson);
              _fullRouteGeometry = decoded.map((e) => LatLng((e['lat'] as num).toDouble(), (e['lng'] as num).toDouble())).toList();
              debugPrint('✅ Loaded route geometry from local cache!');
            } catch(e) {
              debugPrint('Error parsing cached geometry: $e');
            }
          }
        }
        
        if (_fullRouteGeometry == null) {
          Get.snackbar(
            'Offline Mode / Route Error',
            'Could not fetch road geometry. Drawing a direct straight line instead.',
            backgroundColor: Colors.orange.shade700,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
          _fullRouteGeometry = cleanWaypoints; // Fallback to straight lines
        }
      }
    }

    if (_fullRouteGeometry == null || _fullRouteGeometry!.isEmpty) return;

    // 2. Find the closest point on the route to the current GPS location
    int closestIndex = 0;
    if (_hasRealGPS) {
      double minDistance = double.infinity;
      for (int i = 0; i < _fullRouteGeometry!.length; i++) {
        final p = _fullRouteGeometry![i];
        final dist = Geolocator.distanceBetween(
          vehicleLat.value, vehicleLng.value,
          p.latitude, p.longitude,
        );
        if (dist < minDistance) {
          minDistance = dist;
          closestIndex = i;
        }
      }
    }

    // 3. Split the route into passed (blue) and remaining (orange)
    final passedGeometry = _fullRouteGeometry!.sublist(0, closestIndex + 1);
    final remainingGeometry = _fullRouteGeometry!.sublist(closestIndex);

    // Clear old lines
    if (_passedRouteLine != null) {
      try { await mapController!.removeLine(_passedRouteLine!); } catch (_) {}
      _passedRouteLine = null;
    }
    if (_remainingRouteLine != null) {
      try { await mapController!.removeLine(_remainingRouteLine!); } catch (_) {}
      _remainingRouteLine = null;
    }
    if (_routeLine != null) { // For backwards compatibility with old line var
      try { await mapController!.removeLine(_routeLine!); } catch (_) {}
      _routeLine = null;
    }

    // 4. Draw passed route (Blue)
    if (passedGeometry.length > 1) {
      try {
        _passedRouteLine = await mapController!.addLine(LineOptions(
          geometry: passedGeometry,
          lineColor: '#2196F3', // Blue
          lineWidth: 8.0,
          lineOpacity: 0.4,
          lineJoin: 'round',
        ));
      } catch (_) {}
    }

    // 5. Draw remaining route (Orange)
    if (remainingGeometry.length > 1) {
      try {
        _remainingRouteLine = await mapController!.addLine(LineOptions(
          geometry: remainingGeometry,
          lineColor: '#F28546', // Orange
          lineWidth: 8.0,
          lineOpacity: 0.4,
          lineJoin: 'round',
        ));
      } catch (_) {}
    }

    _simulatedPath = _fullRouteGeometry!;
    if (_simulationTimer == null && _isSimulating) {
      _startSimulation();
    }
  }

  void _startSimulation() {
    _simulationTimer?.cancel();
  }

  Future<Uint8List> loadCarImage() async {
    final ByteData data = await rootBundle.load('assets/images/truck_icon.png');
    final Uint8List bytes = data.buffer.asUint8List();

    final ui.Codec codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: 150,
    );

    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ui.Image resizedImage = frameInfo.image;

    final ByteData? resizedData = await resizedImage.toByteData(
      format: ui.ImageByteFormat.png,
    );
    return resizedData!.buffer.asUint8List();
  }
}
