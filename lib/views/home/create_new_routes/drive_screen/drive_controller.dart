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
import 'package:right_routes/core/constants/services/api_logger_interceptor.dart';
import 'package:right_routes/core/constants/api_config/map_config.dart';
import 'package:right_routes/core/constants/services/route_permit_service.dart';
import 'package:right_routes/core/constants/services/offline_route_service.dart';
import 'package:right_routes/utils/map_icon_util.dart';
import 'package:flutter_tts/flutter_tts.dart';

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

  final FlutterTts _tts = FlutterTts();
  final RxBool isVoiceMuted = false.obs;
  final RxString currentGuidanceText = 'Drive on this road for 10.3 miles.'.obs;
  int _nextWaypointIndex = 1;
  bool _notified500m = false;
  bool _notified100m = false;
  String _lastSpoken = '';

  void showPopDown(
    String title,
    String message, {
    Color? backgroundColor,
    Duration? duration,
    SnackPosition snackPosition = SnackPosition.TOP,
  }) {
    Get.snackbar(
      title,
      message,
      titleText: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 19.0, // 3 pts larger than default 16
          fontWeight: FontWeight.bold,
          fontFamily: 'Lato',
        ),
      ),
      messageText: Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 17.0, // 3 pts larger than default 14
          fontFamily: 'Lato',
        ),
      ),
      snackPosition: snackPosition,
      backgroundColor: backgroundColor ?? Colors.blue.withValues(alpha: 0.9),
      colorText: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      borderRadius: 10,
      duration: duration ?? const Duration(seconds: 4),
    );
  }

  @override
  void onInit() {
    super.onInit();
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _initTts();
    _initFromArguments();
    _requestPermission();
    startDriveApi();
  }

  bool _isApiHandled = false;

  @override
  void onClose() {
    _tts.stop();
    _simulationTimer?.cancel();
    _positionSubscription?.cancel();
    _rotationController.dispose();
    if (!_isApiHandled) {
      stopDriveApi();
    }
    super.onClose();
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      await _tts.awaitSpeakCompletion(true);
    } catch (e) {
      debugPrint('TTS Init Error: $e');
    }
  }

  Future<void> speak(String text) async {
    if (text.isEmpty) return;
    currentGuidanceText.value = text;
    if (isVoiceMuted.value) return;
    if (_lastSpoken == text) return;
    _lastSpoken = text;
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (e) {
      debugPrint('TTS Speak Error: $e');
    }
  }

  void toggleVoiceMute() {
    isVoiceMuted.value = !isVoiceMuted.value;
    if (isVoiceMuted.value) {
      _tts.stop();
    } else {
      speak('Voice guidance enabled');
    }
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
          if (waypointPositions.length >= 2) {
            final distMeters = Geolocator.distanceBetween(
              waypointPositions[0].latitude,
              waypointPositions[0].longitude,
              waypointPositions[1].latitude,
              waypointPositions[1].longitude,
            );
            final distMiles = distMeters / 1609.34;
            final formatted = distMiles >= 0.2
                ? '${distMiles.toStringAsFixed(1)} miles'
                : '${(distMeters * 3.28084).round()} feet';
            currentGuidanceText.value = 'Drive on this road for $formatted.';
          }
        }
      }

      if (args['routeId'] != null) {
        routeId = args['routeId'].toString();
      }

      if (waypointPositions.isEmpty && routeId.isNotEmpty) {
        Future.microtask(() async {
          final offlineRoutes = await OfflineRouteService.getOfflineRoutes();
          final match = offlineRoutes.firstWhereOrNull(
              (r) => r['routeId']?.toString() == routeId);
          if (match != null) {
            final wpList = match['waypoints'] as List? ?? [];
            waypointPositions = wpList
                .map((wp) => LatLng(
                    (wp['lat'] as num).toDouble(), (wp['lng'] as num).toDouble()))
                .toList();
            if (waypointPositions.isNotEmpty) {
              vehicleLat.value = waypointPositions.first.latitude;
              vehicleLng.value = waypointPositions.first.longitude;
              _previousLat = vehicleLat.value;
              _previousLng = vehicleLng.value;
              await addWaypointMarkers();
              await drawRoute();
            }
          }
        });
      }
    }
  }

  Future<void> startDriveApi() async {
    if (routeId.isEmpty) return;
    try {
      final success = await RoutePermitService.startDrive(routeId);
      if (success && !isClosed) {
        showPopDown(
          'Drive Started',
          'Server navigation state started',
          backgroundColor: Colors.green.withValues(alpha: 0.9),
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
        showPopDown(
          'Drive Stopped',
          'Server navigation state stopped',
          backgroundColor: Colors.orange.withValues(alpha: 0.9),
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
    if (isDownloading.value) return;

    List<LatLng> targetPoints = List.from(waypointPositions);
    if (targetPoints.isEmpty) {
      if (vehicleLat.value != 0.0 && vehicleLng.value != 0.0) {
        targetPoints.add(LatLng(vehicleLat.value, vehicleLng.value));
      } else if (mapController?.cameraPosition != null) {
        targetPoints.add(mapController!.cameraPosition!.target);
      }
    }

    if (targetPoints.isEmpty) {
      showPopDown(
        'Location Required',
        'Cannot download map: current location or route waypoints are not available.',
        backgroundColor: Colors.orange.withValues(alpha: 0.9),
        duration: const Duration(seconds: 3),
      );
      return;
    }

    isDownloading.value = true;
    downloadProgress.value = 0.0;

    showPopDown(
      'Downloading Map',
      'Downloading map for offline usage. Please stay on this screen...',
      backgroundColor: Colors.blue.withValues(alpha: 0.9),
      duration: const Duration(seconds: 4),
    );

    try {
      double minLat, maxLat, minLng, maxLng;
      if (targetPoints.length == 1) {
        final center = targetPoints.first;
        const delta = 0.035; // ~4 km radius
        minLat = center.latitude - delta;
        maxLat = center.latitude + delta;
        minLng = center.longitude - delta;
        maxLng = center.longitude + delta;
      } else {
        minLat = targetPoints[0].latitude;
        maxLat = targetPoints[0].latitude;
        minLng = targetPoints[0].longitude;
        maxLng = targetPoints[0].longitude;

        for (var point in targetPoints) {
          if (point.latitude < minLat) minLat = point.latitude;
          if (point.latitude > maxLat) maxLat = point.latitude;
          if (point.longitude < minLng) minLng = point.longitude;
          if (point.longitude > maxLng) maxLng = point.longitude;
        }

        final latPadding = ((maxLat - minLat) * 0.1).clamp(0.02, 0.5);
        final lngPadding = ((maxLng - minLng) * 0.1).clamp(0.02, 0.5);

        minLat = minLat - latPadding;
        maxLat = maxLat + latPadding;
        minLng = minLng - lngPadding;
        maxLng = maxLng + lngPadding;
      }

      minLat = minLat.clamp(-85.0, 85.0);
      maxLat = maxLat.clamp(-85.0, 85.0);
      minLng = minLng.clamp(-180.0, 180.0);
      maxLng = maxLng.clamp(-180.0, 180.0);

      final latSpan = (maxLat - minLat).abs();
      final lngSpan = (maxLng - minLng).abs();
      final maxSpan = latSpan > lngSpan ? latSpan : lngSpan;

      double dynamicMinZoom = 12.0;
      double dynamicMaxZoom = 15.0;

      if (maxSpan > 10.0) {
        dynamicMinZoom = 6.0;
        dynamicMaxZoom = 9.0;
      } else if (maxSpan > 2.0) {
        dynamicMinZoom = 8.0;
        dynamicMaxZoom = 12.0;
      } else if (maxSpan > 0.5) {
        dynamicMinZoom = 10.0;
        dynamicMaxZoom = 13.0;
      } else if (maxSpan > 0.1) {
        dynamicMinZoom = 11.0;
        dynamicMaxZoom = 14.0;
      } else {
        dynamicMinZoom = 12.0;
        dynamicMaxZoom = 15.0;
      }

      debugPrint('🗺️ [OfflineMap] Downloading bounds: ($minLat, $minLng) to ($maxLat, $maxLng), Zoom: $dynamicMinZoom -> $dynamicMaxZoom');

      final definition = OfflineRegionDefinition(
        bounds: LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        mapStyleUrl: MapConfig.mapStyle,
        minZoom: dynamicMinZoom,
        maxZoom: dynamicMaxZoom,
      );

      final completer = Completer<void>();

      await downloadOfflineRegion(
        definition,
        metadata: {
          'name': routeId.isNotEmpty ? 'Route $routeId' : 'Drive Route Offline Map',
        },
        onEvent: (status) {
          if (status is InProgress) {
            downloadProgress.value = (status.progress / 100.0).clamp(0.0, 1.0);
            debugPrint('📥 [OfflineMap] Progress: ${(status.progress).toStringAsFixed(1)}%');
          } else if (status is Success) {
            downloadProgress.value = 1.0;
            debugPrint('✅ [OfflineMap] Download succeeded!');
            if (!completer.isCompleted) completer.complete();
          } else if (status is Error) {
            debugPrint('❌ [OfflineMap] Error event: ${status.cause}');
            if (!completer.isCompleted) completer.completeError(status.cause);
          }
        },
      );

      await completer.future.timeout(const Duration(seconds: 120), onTimeout: () {
        debugPrint('⚠️ [OfflineMap] Download timed out after 120s, saving cached progress');
      });

      final String generatedRouteId = routeId.isNotEmpty ? routeId : 'route_${DateTime.now().millisecondsSinceEpoch}';
      await OfflineRouteService.saveOfflineRoute(
        routeId: generatedRouteId,
        routeName: routeId.isNotEmpty ? 'Route $routeId' : 'Saved Offline Area',
        waypoints: targetPoints,
      );

      isDownloading.value = false;

      showPopDown(
        'Download Complete',
        'Map has been successfully saved for offline use.',
        backgroundColor: Colors.green.withValues(alpha: 0.9),
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      isDownloading.value = false;
      debugPrint('❌ [DriveController] Error downloading offline map: $e');

      String errorMsg = 'Failed to download map: $e';
      if (e.toString().contains('429') || e.toString().contains('RATE_LIMIT')) {
        errorMsg = 'Route is too large to download at once. Please try a smaller area.';
      }

      showPopDown(
        'Download Failed',
        errorMsg,
        backgroundColor: Colors.red.withValues(alpha: 0.9),
        duration: const Duration(seconds: 5),
      );
    }
  }

  Future<void> cancelDriveApi() async {
    if (routeId.isEmpty || _isApiHandled) return;
    _isApiHandled = true;
    try {
      final success = await RoutePermitService.cancelDrive(routeId);
      if (success && !isClosed) {
        showPopDown(
          'Drive Cancelled',
          'Server navigation state cancelled',
          backgroundColor: Colors.red.withValues(alpha: 0.9),
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
      showPopDown(
        'Permission Required',
        'Please enable location permission',
        backgroundColor: Colors.red.withValues(alpha: 0.9),
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
      speak('Starting route navigation. Follow the highlighted road.');
    } else {
      showPopDown(
        'Error',
        'No route data or location available',
        backgroundColor: Colors.red.withValues(alpha: 0.9),
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
      _checkTurnByTurnGuidance(position.latitude, position.longitude);

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

  void _checkTurnByTurnGuidance(double lat, double lng) {
    if (waypointPositions.isEmpty) return;
    if (_nextWaypointIndex >= waypointPositions.length) return;

    final targetWp = waypointPositions[_nextWaypointIndex];
    final distMeters = Geolocator.distanceBetween(lat, lng, targetWp.latitude, targetWp.longitude);
    final distMiles = distMeters / 1609.34;

    final isDestination = _nextWaypointIndex == waypointPositions.length - 1;
    final wpName = isDestination ? 'your destination' : 'waypoint $_nextWaypointIndex';

    if (distMeters <= 60) {
      if (isDestination) {
        speak('You have arrived at your destination.');
        _nextWaypointIndex++;
      } else {
        speak('Arrived at $wpName. Proceeding to next waypoint.');
        _nextWaypointIndex++;
        _notified500m = false;
        _notified100m = false;
      }
      return;
    }

    if (distMeters <= 150 && !_notified100m) {
      _notified100m = true;
      speak('In 500 feet, reach $wpName.');
      return;
    }

    if (distMeters <= 500 && !_notified500m) {
      _notified500m = true;
      speak('In a quarter mile, continue towards $wpName.');
      return;
    }

    // Continuous road guidance matching sample: "Drive on this road for X.X miles."
    if (!_notified100m && !_notified500m) {
      final formatted = distMiles >= 0.2
          ? '${distMiles.toStringAsFixed(1)} miles'
          : '${(distMeters * 3.28084).round()} feet';
      currentGuidanceText.value = 'Drive on this road for $formatted.';
    }
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
            iconSize: 1.3, // Larger pin icon
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
              iconSize: 0.75, // Significantly larger pin (was 0.45)
              textField: '$i',
              textSize: 15.0, // Larger waypoint number (was 10.0)
              textOffset: const Offset(0, 0.4),
              textColor: '#FFFFFF',
              textHaloColor: '#000000',
              textHaloWidth: 2.0,
              textHaloBlur: 0.8,
              textAnchor: 'center',
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
      final coords = points.map((p) => '${p.longitude},${p.latitude}').join(';');
      final uri = Uri.parse('https://router.project-osrm.org/route/v1/driving/$coords?overview=full&geometries=geojson');
      try {
        final stopwatch = Stopwatch()..start();
        final res = await http.get(
          uri,
          headers: {'User-Agent': 'RightRoutes/1.0'},
        ).timeout(const Duration(seconds: 15));
        stopwatch.stop();

        ApiLogger.logHttp(
          method: 'GET',
          url: uri,
          statusCode: res.statusCode,
          responseBody: res.body,
          duration: stopwatch.elapsed,
        );

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
        ApiLogger.logHttp(
          method: 'GET',
          url: uri,
          statusCode: 0,
          error: e.toString(),
        );
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
          showPopDown(
            'Offline Mode / Route Error',
            'Could not fetch road geometry. Drawing a direct straight line instead.',
            backgroundColor: Colors.orange.shade700,
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
