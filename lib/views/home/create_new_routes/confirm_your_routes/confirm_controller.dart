import 'dart:math' show Point;
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:right_routes/core/constants/services/api_client.dart';
import 'package:right_routes/core/constants/services/route_permit_service.dart';
import 'package:right_routes/core/constants/api_config/home_api_constant/home_api_constant.dart';
import 'package:right_routes/views/home/create_new_routes/home_controller.dart';
import 'package:right_routes/utils/map_icon_util.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart' as dio;

class PermitState {
  final String permitId;
  final RxList<TextEditingController> waypointControllers = <TextEditingController>[].obs;
  final RxList<String> waypoints = <String>[].obs;
  final RxList<int?> waypointIds = <int?>[].obs;
  final List<LatLng> positions = [];
  final List<bool> selectedStates = [];
  final RxBool isExpanded = false.obs;

  PermitState({required this.permitId});

  void dispose() {
    for (var ctrl in waypointControllers) {
      ctrl.dispose();
    }
  }
}

/// Controller for the Confirm & Edit Your Route screen.
class ConfirmRouteController extends GetxController {
  // ─────────────────────────────────────────────────────────────
  // CONSTANTS
  // ─────────────────────────────────────────────────────────────
  static const String _maptilerKey = 'N2YLLvhtmoQzVSf9VfF9';
  static const String _osrmBase =
      'https://router.project-osrm.org/route/v1/driving';
  static const Duration _osrmTimeout = Duration(seconds: 15);
  static const int _osrmMaxRetries = 2;
  static const double _pinTapThreshold = 0.003;

  // ─────────────────────────────────────────────────────────────
  // PUBLIC OBSERVABLES  (view binds here)
  // ─────────────────────────────────────────────────────────────
  final RxString distance = '0.0 miles'.obs;
  final RxBool isMapReady = false.obs;
  final RxBool isRouteLoading = false.obs;
  final RxBool isAddingPinMode = false.obs;

  final RxList<PermitState> editablePermits = <PermitState>[].obs;

  // Global map state
  final RxInt selectedPermitIndex = (-1).obs;
  final RxInt selectedWaypointIndex = (-1).obs;
  final RxBool isDragging = false.obs;

  // ─────────────────────────────────────────────────────────────
  // PUBLIC NON-REACTIVE  (set once, read by view)
  final TextEditingController routeNameController = TextEditingController();
  LatLng currentLocation = const LatLng(39.8283, -98.5795);

  String? currentRouteId;
  String? currentPermitId;
  final RxList<Map<String, dynamic>> allPermits = <Map<String, dynamic>>[].obs;

  void togglePermitExpanded(int index) {
    if (index >= 0 && index < editablePermits.length) {
      editablePermits[index].isExpanded.value = !editablePermits[index].isExpanded.value;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // PRIVATE MAP STATE
  // ─────────────────────────────────────────────────────────────
  MapLibreMapController? mapController;

  final List<Symbol> _waypointSymbols = [];
  final List<Line> _routeLines = [];
  
  LatLng _mapCenter = const LatLng(39.8283, -98.5795);
  double _mapZoom = 11.0;
  bool _iconsLoaded = false;
  int? _draggingPinIndex;
  int _routeGeneration = 0;

  // ─────────────────────────────────────────────────────────────
  // LIFECYCLE
  // ─────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    routeNameController.text = '';
    _initializeFromArguments();
    // Location permission removed - no automatic location fetching
  }

  @override
  void onClose() {
    _waypointDebouncer?.cancel();
    _routeNameDebouncer?.cancel();
    routeNameController.dispose();
    for (var p in editablePermits) {
      p.dispose();
    }
    mapController = null;
    super.onClose();
  }

  // ─────────────────────────────────────────────────────────────
  // INITIALIZATION
  // ─────────────────────────────────────────────────────────────
  void _initializeFromArguments() {
    try {
      final args = Get.arguments;
      if (args is! Map) {
        _setDefaultWaypoints();
        return;
      }

      final startLocation = args['startLocation'] as String?;
      final endLocation = args['endLocation'] as String?;
      final routeSegments =
          (args['routeSegments'] as List?)?.cast<String>() ?? <String>[];
      final permitType = args['permitType'] as String?;
      final rawCoords = (args['routeWithCoordinates'] as List?) ?? [];
      final coordsList =
          rawCoords.map((e) => Map<String, dynamic>.from(e as Map)).toList();

      _clearWaypointControllers();
      final permitState = PermitState(permitId: 'new');
      editablePermits.add(permitState);

      final startLatStr = args['startLat'] as String?;
      final startLngStr = args['startLng'] as String?;

      if (startLatStr != null && startLngStr != null && startLatStr.isNotEmpty && startLngStr.isNotEmpty) {
        currentLocation = LatLng(double.parse(startLatStr), double.parse(startLngStr));
        _mapCenter = currentLocation;
      }

      LatLng? coordFor(String label) {
        for (final c in coordsList) {
          if (c['location'].toString() == label) {
            return LatLng(
              (c['lat'] as num).toDouble(),
              (c['lng'] as num).toDouble(),
            );
          }
        }
        return null;
      }

      final routeId = args['routeId']?.toString();
      final permitId = args['permitId']?.toString();

      if (routeId != null && permitId != null) {
         fetchRouteDetails(routeId); // Just fetch the route since it fetches all permits
      } else if (routeId != null) {
        fetchRouteDetails(routeId);
      } else {
        // Fallback to static arguments if no IDs provided
        final startLabel = (startLocation?.isNotEmpty == true)
            ? startLocation!
            : 'Your current location';
        _appendWaypoint(permitState, startLabel, coordFor(startLabel));

        for (final seg in routeSegments) {
          if (seg.isNotEmpty) _appendWaypoint(permitState, seg, coordFor(seg));
        }

        if (endLocation?.isNotEmpty == true) {
          _appendWaypoint(permitState, endLocation!, coordFor(endLocation));
        }

        if (permitType?.isNotEmpty == true) {
          routeNameController.text = permitType!;
        }

        if (permitState.positions.isNotEmpty) {
          currentLocation = permitState.positions.first;
          _mapCenter = permitState.positions.first;
        }
        permitState.isExpanded.value = true;
      }
    } catch (e) {
      debugPrint('ConfirmRouteController init error: $e');
      _setDefaultWaypoints();
    }
  }

  void _setDefaultWaypoints() {
    _clearWaypointControllers();
    final permitState = PermitState(permitId: 'new');
    permitState.isExpanded.value = true;
    editablePermits.add(permitState);

    _appendWaypoint(permitState, 'Current Location', currentLocation);
    _appendWaypoint(permitState, 'Destination',
        LatLng(currentLocation.latitude + 0.01, currentLocation.longitude + 0.01));
    _mapCenter = currentLocation;

    _fetchRealUserLocation(permitState);
  }

  Future<void> _fetchRealUserLocation(PermitState permitState) async {
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.always || perm == LocationPermission.whileInUse) {
        final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        currentLocation = LatLng(pos.latitude, pos.longitude);
        _mapCenter = currentLocation;

        if (permitState.positions.length >= 2) {
          permitState.positions[0] = currentLocation;
          permitState.positions[1] = LatLng(currentLocation.latitude + 0.01, currentLocation.longitude + 0.01);

          if (isMapReady.value && mapController != null) {
            mapController!.animateCamera(CameraUpdate.newCameraPosition(
              CameraPosition(target: currentLocation, zoom: 14.0),
            ));
            _refreshMap();
          }
        }
      }
    } catch (_) {}
  }

  void _clearWaypointControllers() {
    for (var p in editablePermits) {
      p.dispose();
    }
    editablePermits.clear();
  }

  void _appendWaypoint(PermitState permit, String label, LatLng? coord, [int? id]) {
    permit.waypoints.add(label);
    permit.waypointControllers.add(TextEditingController(text: label));
    permit.selectedStates.add(false);
    permit.waypointIds.add(id);
    permit.positions.add(coord ??
        LatLng(
          currentLocation.latitude + permit.positions.length * 0.01,
          currentLocation.longitude + permit.positions.length * 0.01,
        ));
  }

  // ─────────────────────────────────────────────────────────────
  // API INTEGRATION
  // ─────────────────────────────────────────────────────────────

  Future<void> fetchRouteDetails(String routeId) async {
    try {
      currentRouteId = routeId;
      isRouteLoading.value = true;
      final url = Uri.parse(
          '${HomeApiConstant.baseUrl}${HomeApiConstant.routePost}$routeId/');
      debugPrint('🚀 [FetchRouteDetails] Requesting: $url');

      final response = await ApiClient.get(url);
      final body = response.data;

      if (response.statusCode == 200 && body['success'] == true) {
        final data = body['data'];
        routeNameController.text = data['name'] ?? '';

        final permits = data['permits'] as List? ?? [];
        allPermits.value = List<Map<String, dynamic>>.from(permits);

        // Sync HomeController's currentPermitIndex
        try {
          if (Get.isRegistered<HomeController>()) {
            Get.find<HomeController>().currentPermitIndex.value =
                permits.length;
          }
        } catch (_) {}

        if (permits.isNotEmpty) {
          for (var p in editablePermits) {
            p.dispose();
          }
          editablePermits.clear();

          for (int i = 0; i < permits.length; i++) {
            final permitData = permits[i];
            final permitId = permitData['id']?.toString() ?? '';
            final state = PermitState(permitId: permitId);
            
            // Start location
            final startLocationName = permitData['start_location'] ?? '';
            if (startLocationName.isNotEmpty) {
              _appendWaypoint(
                state,
                startLocationName,
                LatLng((permitData['start_latitude'] as num?)?.toDouble() ?? 0.0,
                    (permitData['start_longitude'] as num?)?.toDouble() ?? 0.0),
                null,
              );
            }

            // Intermediate waypoints
            final wpList = permitData['waypoints'] as List? ?? [];
            for (final wp in wpList) {
              _appendWaypoint(
                state,
                wp['name'] ?? '',
                LatLng((wp['latitude'] as num?)?.toDouble() ?? 0.0,
                    (wp['longitude'] as num?)?.toDouble() ?? 0.0),
                wp['id'],
              );
            }

            // End location
            final endLocationName = permitData['end_location'] ?? '';
            if (endLocationName.isNotEmpty) {
              _appendWaypoint(
                state,
                endLocationName,
                LatLng((permitData['end_latitude'] as num?)?.toDouble() ?? 0.0,
                    (permitData['end_longitude'] as num?)?.toDouble() ?? 0.0),
                null,
              );
            }
            
            // Expand all permits by default so they remain editable
            state.isExpanded.value = true;
            editablePermits.add(state);
          }

          if (editablePermits.isNotEmpty && editablePermits.first.positions.isNotEmpty) {
            currentLocation = editablePermits.first.positions.first;
            _mapCenter = editablePermits.first.positions.first;
          }

          if (isMapReady.value && mapController != null) {
            await _refreshMap();
          }
        }
      }
    } catch (e) {
      debugPrint('❌ [FetchRouteDetails] Error: $e');
    } finally {
      isRouteLoading.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // MAP EVENTS
  final Map<Symbol, Map<String, int>> _symbolToWaypointMapping = {};
  
  void onMapCreated(MapLibreMapController controller) {
    mapController = controller;
    isMapReady.value = true;

    controller.onSymbolTapped.add((symbol) {
      final mapping = _symbolToWaypointMapping[symbol];
      if (mapping != null) {
        _handlePinTap(mapping['permitIndex']!, mapping['waypointIndex']!);
      }
    });

    controller.onFeatureDrag.add((
      Point<double> point,
      LatLng origin,
      LatLng current,
      LatLng delta,
      String id,
      Annotation? annotation,
      DragEventType eventType,
    ) async {
      if (annotation is! Symbol) return;
      final mapping = _symbolToWaypointMapping[annotation];
      if (mapping == null) return;
      
      final permitIndex = mapping['permitIndex']!;
      final wpIndex = mapping['waypointIndex']!;
      final permit = editablePermits[permitIndex];

      if (eventType == DragEventType.start) {
        isDragging.value = true;
        final bool isStartOrEnd = wpIndex == 0 || (wpIndex == permit.positions.length - 1 && permit.positions.length > 1);
        await mapController!.updateSymbol(
            annotation,
            SymbolOptions(
              iconSize: isStartOrEnd ? 2.5 : 1.2,
              iconOffset: const Offset(0, 0),
              textOffset: isStartOrEnd ? null : const Offset(0, 0.6),
            ));
        return;
      }

      if (eventType == DragEventType.drag) {
        return; // MapLibre handles the visual movement during drag natively
      }

      if (eventType == DragEventType.end) {
        isDragging.value = false;

        if (wpIndex < permit.positions.length) {
          permit.positions[wpIndex] = current;
        }

        final bool isStartOrEnd = wpIndex == 0 || (wpIndex == permit.positions.length - 1 && permit.positions.length > 1);
        final bool isSelected = wpIndex < permit.selectedStates.length && permit.selectedStates[wpIndex];
        await mapController!.updateSymbol(
            annotation,
            SymbolOptions(
              iconSize: isStartOrEnd ? (isSelected ? 1.2 : 1.0) : (isSelected ? 0.55 : 0.45),
              iconOffset: const Offset(0, 0),
              textOffset: isStartOrEnd ? null : const Offset(0, 0.6),
            ));

        // 1. Immediately refresh the map with the new positions (draws polyline, fits map, etc.)
        final refreshFuture = _refreshMap();

        // 2. Offload geocoding and server PATCH to background so it doesn't block UI thread/map snapping
        Future.microtask(() async {
          final address =
              await _reverseGeocode(current.latitude, current.longitude);
          if (wpIndex < permit.waypoints.length) {
            permit.waypoints[wpIndex] = address;
            permit.waypoints.refresh();
          }
          if (wpIndex < permit.waypointControllers.length) {
            permit.waypointControllers[wpIndex].text = address;
          }

          // Auto-update to server
          if (currentRouteId != null && permit.permitId != 'new') {
            final wId = permit.waypointIds[wpIndex];
            if (wId != null) {
              final url = Uri.parse(
                  '${HomeApiConstant.baseUrl}/route/$currentRouteId/permit/${permit.permitId}/waypoint/$wId/');
              final formData = dio.FormData.fromMap({
                'latitude': current.latitude.toString(),
                'longitude': current.longitude.toString(),
                'name': address,
              });
              try {
                await ApiClient.sendMultipartRequest(url, data: formData, method: 'PATCH');
              } catch (e) {
                debugPrint('❌ Failed to update waypoint on server: $e');
              }
            }
          }
        });

        await refreshFuture;
      }
    });
  }

  void onCameraMove(CameraPosition position) {
    _mapCenter = position.target;
    _mapZoom = position.zoom;
  }

  Future<void> onStyleLoaded() async {
    if (mapController == null) return;
    try {
      _iconsLoaded = false;
      await _loadIcons();
      await _refreshMap();
    } catch (e) {
      debugPrint('onStyleLoaded error: $e');
    }
  }

  // NEW: Updated onMapClick to handle Add Pin Mode
  Future<void> onMapClick(LatLng point) async {
    if (isAddingPinMode.value) {
      // Add a pin at the tapped location and exit mode
      isAddingPinMode.value = false;
      await _addPinAtLocation(point);
      return;
    }

    final mapping = _pinNear(point);
    if (mapping != null) {
      _handlePinTap(mapping['permitIndex']!, mapping['waypointIndex']!);
    } else {
      _deselectAll();
    }
  }

  Future<void> onMapLongClick(LatLng point) async {
    final mapping = _pinNear(point);
    if (mapping != null) _handlePinTap(mapping['permitIndex']!, mapping['waypointIndex']!);
  }

  // ─────────────────────────────────────────────────────────────
  // MAP DRAWING
  // ─────────────────────────────────────────────────────────────
  Future<void> _refreshMap() async {
    if (mapController == null) return;
    await _drawRealRoadPolyline();
    await _addAllMarkers();
    _calculateDistance();
    _fitMapToWaypoints();
  }

  Future<void> _loadIcons() async {
    if (mapController == null || _iconsLoaded) return;
    try {
      final bytes = await rootBundle.load('assets/icons/Map-Pin-orange.png');
      await mapController!.addImage('pin-orange', bytes.buffer.asUint8List());
      await MapIconUtil.loadStartEndIcons(mapController!);
      _iconsLoaded = true;
    } catch (e) {
      debugPrint('Icon load error: $e');
    }
  }

  Future<void> _addAllMarkers() async {
    if (mapController == null || !_iconsLoaded) return;
    try {
      if (_waypointSymbols.isNotEmpty) {
        await mapController!.removeSymbols(_waypointSymbols);
        _waypointSymbols.clear();
      }
      _symbolToWaypointMapping.clear();

      for (int pIdx = 0; pIdx < editablePermits.length; pIdx++) {
        final permit = editablePermits[pIdx];
        if (!permit.isExpanded.value) continue;

        for (int i = 0; i < permit.positions.length; i++) {
          final isSelected =
              i < permit.selectedStates.length && permit.selectedStates[i];
          final isStart = i == 0;
          final isEnd =
              i == permit.positions.length - 1 && permit.positions.length > 1;

          Symbol sym;
          if (isStart || isEnd) {
            sym = await mapController!.addSymbol(SymbolOptions(
              geometry: permit.positions[i],
              iconImage: isStart ? 'start-icon' : 'end-icon',
              iconSize: isSelected ? 1.2 : 1.0,
              iconAnchor: 'center',
              zIndex: 100,
              draggable: true,
            ));
          } else {
            sym = await mapController!.addSymbol(SymbolOptions(
              geometry: permit.positions[i],
              iconImage: 'pin-orange',
              iconSize: isSelected ? 0.55 : 0.45,
              textField: '$i',
              textSize: 12.0,
              textOffset: const Offset(0, 0.6),
              textColor: '#FFFFFF',
              textHaloColor: '#000000',
              textHaloWidth: 1.8,
              textHaloBlur: 0.8,
              textAnchor: 'center',
              draggable: true,
            ));
          }
          _waypointSymbols.add(sym);
          _symbolToWaypointMapping[sym] = {'permitIndex': pIdx, 'waypointIndex': i};
        }
      }
    } catch (e) {
      debugPrint('❌ [AddMarkers] Error: $e');
    }
  }

  // FIXED: No more stuck "Calculating route"
  Future<void> _drawRealRoadPolyline() async {
    if (mapController == null) return;
    
    // Clear all previous lines
    for (final line in _routeLines) {
      try {
        await mapController!.removeLine(line);
      } catch (_) {}
    }
    _routeLines.clear();

    final generation = ++_routeGeneration;
    isRouteLoading.value = true;

    try {
      if (generation != _routeGeneration) return;

      for (final permit in editablePermits) {
        if (!permit.isExpanded.value || permit.positions.length < 2) continue;
        
        final routeGeometry = await _fetchOsrmRoute(permit);

        if (generation != _routeGeneration) return;
        if (mapController == null) return;

        final line = await mapController!.addLine(LineOptions(
          geometry: routeGeometry,
          lineColor: '#FF6B35',
          lineWidth: 5.0,
          lineOpacity: 0.4,
          lineJoin: 'round',
        ));
        _routeLines.add(line);
      }
    } catch (e) {
      debugPrint('DrawRealRoadPolyline error: $e');
    } finally {
      // Turn OFF loading only for the latest request
      if (generation == _routeGeneration) {
        isRouteLoading.value = false;
      }
    }
  }

  Future<List<LatLng>> _fetchOsrmRoute(PermitState permit) async {
    final points = permit.positions;
    final coordStr =
        points.map((p) => '${p.longitude},${p.latitude}').join(';');
    final uri =
        Uri.parse('$_osrmBase/$coordStr?overview=full&geometries=geojson');

    for (int attempt = 0; attempt <= _osrmMaxRetries; attempt++) {
      try {
        final response = await http.get(uri,
            headers: {'User-Agent': 'RightRoutes/1.0'});

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          
          // Snap waypoint pins to the road
          final waypoints = data['waypoints'] as List?;
          if (waypoints != null && waypoints.length == points.length) {
            for (int i = 0; i < waypoints.length; i++) {
              final loc = waypoints[i]['location'] as List?;
              if (loc != null && loc.length >= 2) {
                permit.positions[i] = LatLng((loc[1] as num).toDouble(), (loc[0] as num).toDouble());
              }
            }
          }

          final routes = data['routes'] as List?;
          if (routes != null && routes.isNotEmpty) {
            final geometry = (routes[0] as Map<String, dynamic>)['geometry']
                as Map<String, dynamic>;
            final coords = geometry['coordinates'] as List;
            return coords
                .map<LatLng>((c) => LatLng(
                      (c[1] as num).toDouble(),
                      (c[0] as num).toDouble(),
                    ))
                .toList();
          }
        }
      } catch (e) {
        debugPrint('OSRM attempt ${attempt + 1} failed: $e');
        if (attempt < _osrmMaxRetries) {
          await Future.delayed(Duration(milliseconds: 500 * (attempt + 1)));
        }
      }
    }

    return List.from(points);
  }

  void _calculateDistance() {
    double totalMeters = 0.0;
    for (final permit in editablePermits) {
      if (!permit.isExpanded.value) continue;
      for (int i = 0; i < permit.positions.length - 1; i++) {
        totalMeters += Geolocator.distanceBetween(
          permit.positions[i].latitude,
          permit.positions[i].longitude,
          permit.positions[i + 1].latitude,
          permit.positions[i + 1].longitude,
        );
      }
    }
    distance.value = '${(totalMeters / 1609.34).toStringAsFixed(1)} miles';
  }

  void _fitMapToWaypoints() {
    if (mapController == null) return;

    List<LatLng> allPositions = [];
    for (final permit in editablePermits) {
      if (permit.isExpanded.value) {
        allPositions.addAll(permit.positions);
      }
    }

    if (allPositions.isEmpty) return;

    try {
      if (allPositions.length == 1) {
        mapController!.animateCamera(
            CameraUpdate.newLatLngZoom(allPositions[0], 13.0));
        return;
      }

      final lats = allPositions.map((p) => p.latitude);
      final lngs = allPositions.map((p) => p.longitude);
      final minLat = lats.reduce((a, b) => a < b ? a : b);
      final maxLat = lats.reduce((a, b) => a > b ? a : b);
      final minLng = lngs.reduce((a, b) => a < b ? a : b);
      final maxLng = lngs.reduce((a, b) => a > b ? a : b);

      final latPad = ((maxLat - minLat) * 0.15).clamp(0.005, 5.0);
      final lngPad = ((maxLng - minLng) * 0.15).clamp(0.005, 5.0);

      mapController!.animateCamera(CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat - latPad, minLng - lngPad),
          northeast: LatLng(maxLat + latPad, maxLng + lngPad),
        ),
        left: 40,
        top: 60,
        right: 40,
        bottom: 60,
      ));
    } catch (e) {
      debugPrint('FitMapToWaypoints error: $e');
    }
  }

  void _handlePinTap(int permitIndex, int wpIndex) {
    if (permitIndex < 0 || permitIndex >= editablePermits.length) return;
    final permit = editablePermits[permitIndex];

    final wasSelected = wpIndex < permit.selectedStates.length &&
        permit.selectedStates[wpIndex];
    _deselectAll();
    
    if (!wasSelected) {
      if (wpIndex < permit.selectedStates.length) {
        permit.selectedStates[wpIndex] = true;
      }
      selectedPermitIndex.value = permitIndex;
      selectedWaypointIndex.value = wpIndex;
    }
    _addAllMarkers();
  }

  void _deselectAll() {
    for (final permit in editablePermits) {
      for (int i = 0; i < permit.selectedStates.length; i++) {
        permit.selectedStates[i] = false;
      }
    }
    selectedPermitIndex.value = -1;
    selectedWaypointIndex.value = -1;
  }

  Map<String, int>? _pinNear(LatLng tap) {
    int? bestPermitIdx;
    int? bestWpIdx;
    double bestDist = double.infinity;

    for (int pIdx = 0; pIdx < editablePermits.length; pIdx++) {
      final permit = editablePermits[pIdx];
      if (!permit.isExpanded.value) continue;

      for (int i = 0; i < permit.positions.length; i++) {
        final d = (tap.latitude - permit.positions[i].latitude).abs() +
            (tap.longitude - permit.positions[i].longitude).abs();
        if (d < _pinTapThreshold && d < bestDist) {
          bestDist = d;
          bestPermitIdx = pIdx;
          bestWpIdx = i;
        }
      }
    }
    if (bestPermitIdx != null && bestWpIdx != null) {
      return {'permitIndex': bestPermitIdx, 'waypointIndex': bestWpIdx};
    }
    return null;
  }

  // ─────────────────────────────────────────────────────────────
  // PUBLIC UI ACTIONS
  // ─────────────────────────────────────────────────────────────
  Future<void> zoomIn() async {
    if (mapController == null) return;
    final z = (_mapZoom + 1).clamp(1.0, 20.0);
    await mapController!.animateCamera(
      CameraUpdate.zoomTo(z),
      duration: const Duration(milliseconds: 300),
    );
    _mapZoom = z;
  }

  Future<void> zoomOut() async {
    if (mapController == null) return;
    final z = (_mapZoom - 1).clamp(1.0, 20.0);
    await mapController!.animateCamera(
      CameraUpdate.zoomTo(z),
      duration: const Duration(milliseconds: 300),
    );
    _mapZoom = z;
  }

  // NEW: Toggle add pin mode
  void toggleAddPinMode() {
    isAddingPinMode.value = !isAddingPinMode.value;
  }

  // NEW: Add pin at specific coordinates with API Call
  Future<void> _addPinAtLocation(LatLng point) async {
    try {
      final address = await _reverseGeocode(point.latitude, point.longitude);
      int? newId;

      int pIdx = selectedPermitIndex.value != -1 ? selectedPermitIndex.value : editablePermits.length - 1;
      if (pIdx < 0 || pIdx >= editablePermits.length) return;
      
      final permit = editablePermits[pIdx];

      if (currentRouteId != null && permit.permitId != 'new') {
        final url = Uri.parse(
            '${HomeApiConstant.baseUrl}/route/$currentRouteId/permit/${permit.permitId}/waypoint/');

        final formData = dio.FormData.fromMap({
          'latitude': point.latitude.toString(),
          'longitude': point.longitude.toString(),
          'name': address,
        });

        final response = await ApiClient.sendMultipartRequest(url,
            data: formData, method: 'POST');
        if (response.statusCode == 201 || response.statusCode == 200) {
          Get.snackbar('Success', 'Waypoint added to server',
              backgroundColor: Colors.green, colorText: Colors.white);
          fetchRouteDetails(currentRouteId!); // Refresh everything
          return;
        } else {
          Get.snackbar('Error', 'Failed to add waypoint to server',
              backgroundColor: Colors.redAccent, colorText: Colors.white);
        }
      }

      if (permit.waypoints.length >= 2) {
        int insertIndex = permit.waypoints.length - 1;
        permit.waypoints.insert(insertIndex, address);
        permit.waypointControllers.insert(
            insertIndex, TextEditingController(text: address));
        permit.selectedStates.insert(insertIndex, false);
        permit.waypointIds.insert(insertIndex, newId);
        permit.positions.insert(insertIndex, point);
      } else {
        _appendWaypoint(permit, address, point, newId);
      }
      await _refreshMap();
    } catch (e) {
      debugPrint("❌ Add waypoint error: $e");
    }
  }

  // Kept for backward compatibility
  Future<void> addMapPin() async {
    toggleAddPinMode();
  }

  // FIXED: Delete pin with API call
  Future<void> deleteWaypointAt(int pIdx, int wpIdx) async {
    if (pIdx < 0 || pIdx >= editablePermits.length) return;
    final permit = editablePermits[pIdx];

    if (wpIdx < 0 || wpIdx >= permit.waypoints.length) return;
    if (permit.waypoints.length <= 2) {
      Get.snackbar('Cannot remove', 'A route needs at least 2 waypoints',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    // Call DELETE API if we have an ID
    final wId = permit.waypointIds[wpIdx];
    if (wId != null && currentRouteId != null && permit.permitId != 'new') {
      final url = Uri.parse(
          '${HomeApiConstant.baseUrl}/route/$currentRouteId/permit/${permit.permitId}/waypoint/$wId/');

      final response = await ApiClient.delete(url, headers: {
        'Content-Type': 'application/json',
      });

      if (response.statusCode != 200 && response.statusCode != 204) {
        Get.snackbar('Error', 'Failed to delete waypoint on server',
            backgroundColor: Colors.redAccent, colorText: Colors.white);
        return;
      }
    }

    // Safely remove locally
    permit.waypoints.removeAt(wpIdx);
    final controllerToDispose = permit.waypointControllers[wpIdx];
    permit.waypointControllers.removeAt(wpIdx);
    controllerToDispose.dispose();

    permit.positions.removeAt(wpIdx);
    permit.selectedStates.removeAt(wpIdx);
    permit.waypointIds.removeAt(wpIdx);

    if (selectedPermitIndex.value == pIdx) {
      if (selectedWaypointIndex.value == wpIdx) {
        selectedWaypointIndex.value = -1;
      } else if (selectedWaypointIndex.value > wpIdx) {
        selectedWaypointIndex.value -= 1;
      }
    }
    await _refreshMap();
  }

  Future<void> deleteSelectedMapPin() async {
    final pIdx = selectedPermitIndex.value;
    final wpIdx = selectedWaypointIndex.value;
    if (pIdx == -1 || wpIdx == -1) {
      Get.snackbar('No pin selected', 'Tap a pin on the map to select it',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }
    await deleteWaypointAt(pIdx, wpIdx);
  }

  void deleteSelectedWaypoint() => deleteSelectedMapPin();

  Future<void> updateRoute() async {
    // API UPDATE for selected waypoint
    final pIdx = selectedPermitIndex.value;
    final wpIdx = selectedWaypointIndex.value;
    
    if (pIdx != -1 && wpIdx != -1 && currentRouteId != null) {
      final permit = editablePermits[pIdx];
      if (permit.permitId != 'new') {
        final wId = permit.waypointIds[wpIdx];
        if (wId != null) {
          final url = Uri.parse(
              '${HomeApiConstant.baseUrl}/route/$currentRouteId/permit/${permit.permitId}/waypoint/$wId/');

          final point = permit.positions[wpIdx];
          final name = permit.waypointControllers[wpIdx].text;

          final formData = dio.FormData.fromMap({
            'latitude': point.latitude.toString(),
            'longitude': point.longitude.toString(),
            'name': name,
          });

          final response = await ApiClient.sendMultipartRequest(url,
              data: formData, method: 'PATCH');
          if (response.statusCode == 200 || response.statusCode == 201) {
            Get.snackbar('Success', 'Waypoint updated on server',
                backgroundColor: Colors.green, colorText: Colors.white);
          } else {
            Get.snackbar('Error', 'Failed to update waypoint on server',
                backgroundColor: Colors.redAccent, colorText: Colors.white);
          }
        } else {
          Get.snackbar('Local Update',
              'Waypoint updated locally (not yet saved to server)',
              backgroundColor: Colors.orange, colorText: Colors.white);
        }
      }
    }

    // Refresh UI texts
    for (final permit in editablePermits) {
      for (int i = 0; i < permit.waypointControllers.length; i++) {
        if (i < permit.waypoints.length) permit.waypoints[i] = permit.waypointControllers[i].text;
      }
      permit.waypoints.refresh();
    }
    await _refreshMap();
  }

  void selectWaypoint(int pIdx, int wpIdx) {
    if (pIdx < 0 || pIdx >= editablePermits.length) return;
    final permit = editablePermits[pIdx];
    if (wpIdx < 0 || wpIdx >= permit.waypoints.length) return;
    
    final wasSelected = wpIdx < permit.selectedStates.length &&
        permit.selectedStates[wpIdx];
    _deselectAll();
    if (!wasSelected) {
      if (wpIdx < permit.selectedStates.length) {
        permit.selectedStates[wpIdx] = true;
      }
      selectedPermitIndex.value = pIdx;
      selectedWaypointIndex.value = wpIdx;
    }
    _addAllMarkers();
  }

  Timer? _waypointDebouncer;

  void updateWaypoint(int pIdx, int wpIdx, String val) {
    if (pIdx < 0 || pIdx >= editablePermits.length) return;
    final permit = editablePermits[pIdx];

    if (wpIdx >= 0 && wpIdx < permit.waypoints.length) {
      permit.waypoints[wpIdx] = val;
      permit.waypoints.refresh();

      if (_waypointDebouncer?.isActive ?? false) {
        _waypointDebouncer!.cancel();
      }
      _waypointDebouncer = Timer(const Duration(milliseconds: 1000), () async {
        try {
          if (val.isNotEmpty) {
            // Geocode the typed address
            List<Location> locations = await locationFromAddress(val).timeout(const Duration(seconds: 8));
            if (locations.isNotEmpty) {
              final loc = locations.first;
              final newPos = LatLng(loc.latitude, loc.longitude);
              permit.positions[wpIdx] = newPos;
              await _refreshMap(); // Update the map to show the new location
              
              if (currentRouteId != null && permit.permitId != 'new') {
                final wId = permit.waypointIds[wpIdx];
                if (wId != null) {
                  final url = Uri.parse(
                      '${HomeApiConstant.baseUrl}/route/$currentRouteId/permit/${permit.permitId}/waypoint/$wId/');
                  final formData = dio.FormData.fromMap({
                    'latitude': newPos.latitude.toString(),
                    'longitude': newPos.longitude.toString(),
                    'name': val,
                  });
                  await ApiClient.sendMultipartRequest(url, data: formData, method: 'PATCH');
                }
              }
            }
          }
        } catch (e) {
          debugPrint('Geocoding error or API error: $e');
        }
      });
    }
  }

  Timer? _routeNameDebouncer;

  void updateRouteName(String val) {
    if (routeNameController.text != val) {
      routeNameController.text = val;
    }

    if (currentRouteId != null && val.isNotEmpty) {
      if (_routeNameDebouncer?.isActive ?? false) {
        _routeNameDebouncer!.cancel();
      }
      _routeNameDebouncer = Timer(const Duration(milliseconds: 1000), () {
        _updateRouteNameApi(val);
      });
    }
  }

  Future<void> _updateRouteNameApi(String newName) async {
    if (currentRouteId == null) return;
    try {
      final url = Uri.parse(
          '${HomeApiConstant.baseUrl}${HomeApiConstant.updateRouteName}$currentRouteId/update-name/');
      debugPrint('🚀 [UpdateRouteName] Requesting: $url');

      final response = await ApiClient.patch(
        url,
        body: {'name': newName},
      );

      final body = response.data;
      if (response.statusCode == 200 && body['success'] == true) {
        debugPrint('✅ [UpdateRouteName] Successfully updated to: $newName');
      } else {
        debugPrint(
            '⚠️ [UpdateRouteName] API returned non-success: ${body['message']}');
      }
    } catch (e) {
      debugPrint('❌ [UpdateRouteName] Error: $e');
    }
  }

  void addWaypointAt(int pIdx, int wpIdx) async {
    if (pIdx < 0 || pIdx >= editablePermits.length) return;
    final permit = editablePermits[pIdx];

    if (wpIdx >= permit.positions.length) return;
    final p1 = permit.positions[wpIdx];
    final p2 = (wpIdx < permit.positions.length - 1)
        ? permit.positions[wpIdx + 1]
        : LatLng(p1.latitude + 0.01, p1.longitude + 0.01);
    final mid = LatLng(
      (p1.latitude + p2.latitude) / 2,
      (p1.longitude + p2.longitude) / 2,
    );
    
    if (currentRouteId != null && permit.permitId != 'new') {
      final url = Uri.parse(
          '${HomeApiConstant.baseUrl}/route/$currentRouteId/permit/${permit.permitId}/waypoint/');
      final formData = dio.FormData.fromMap({
        'latitude': mid.latitude.toString(),
        'longitude': mid.longitude.toString(),
        'name': 'New Stop',
      });
      final response = await ApiClient.sendMultipartRequest(url, data: formData, method: 'POST');
      if (response.statusCode == 201 || response.statusCode == 200) {
        fetchRouteDetails(currentRouteId!); // Refresh all permits
        return;
      }
    }

    permit.waypoints.insert(wpIdx + 1, 'New Stop');
    permit.waypointControllers.insert(
        wpIdx + 1, TextEditingController(text: 'New Stop'));
    permit.positions.insert(wpIdx + 1, mid);
    permit.selectedStates.insert(wpIdx + 1, false);
    permit.waypointIds.insert(wpIdx + 1, null);
    _refreshMap();
  }

  // ─────────────────────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────────────────────

  Future<String> _reverseGeocode(double lat, double lng) async {
    try {
      final places = await placemarkFromCoordinates(lat, lng)
          .timeout(const Duration(seconds: 8));
      if (places.isNotEmpty) {
        final p = places.first;
        final parts = <String>[
          if (p.street?.isNotEmpty == true) p.street!,
          if (p.locality?.isNotEmpty == true) p.locality!,
          if (p.administrativeArea?.isNotEmpty == true) p.administrativeArea!,
        ];
        if (parts.isNotEmpty) return parts.join(', ');
      }
    } catch (_) {}
    return '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';
  }

  List<LatLng> get waypointPositions {
    final List<LatLng> all = [];
    for (final permit in editablePermits) {
      if (permit.isExpanded.value) {
        all.addAll(permit.positions);
      }
    }
    return List.unmodifiable(all);
  }
}
