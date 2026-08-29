import 'dart:math';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:get/get.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:right_routes/core/constants/services/api_client.dart';
import 'package:right_routes/views/home/create_new_routes/confirm_your_routes/create_route_after_confirm_route/after_confirm_controller.dart';
import 'package:right_routes/utils/map_icon_util.dart';

class AfterConfirmMap extends StatefulWidget {
  final bool isFullScreen;
  const AfterConfirmMap({super.key, this.isFullScreen = false});

  @override
  State<AfterConfirmMap> createState() => _AfterConfirmMapState();
}

class _AfterConfirmMapState extends State<AfterConfirmMap> {
  MapLibreMapController? mapController;
  final AfterConfirmController _ctrl = Get.find<AfterConfirmController>();

  Symbol? _startSymbol;
  Symbol? _endSymbol;
  Line? _routeLine;
  double _routeDistanceMeters = 0.0;
  int _pickingState = 0; // 0=Start, 1=End, 2=Done
  
  LatLng? _initialPosition;
  bool _isLoadingInitialLocation = true;

  @override
  void initState() {
    super.initState();
    _determineInitialLocation();
  }

  Future<void> _determineInitialLocation() async {
    if (_ctrl.startLat.value.isNotEmpty && _ctrl.startLng.value.isNotEmpty) {
      double? lat = double.tryParse(_ctrl.startLat.value);
      double? lng = double.tryParse(_ctrl.startLng.value);
      if (lat != null && lng != null) {
        if (mounted) {
          setState(() {
            _initialPosition = LatLng(lat, lng);
            _isLoadingInitialLocation = false;
          });
        }
        return;
      }
    }
    
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _setFallbackLocation();
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _setFallbackLocation();
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        _setFallbackLocation();
        return;
      }
      
      Position? pos = await Geolocator.getLastKnownPosition();
      if (pos != null) {
        if (mounted) {
          setState(() {
            _initialPosition = LatLng(pos!.latitude, pos.longitude);
            _isLoadingInitialLocation = false;
          });
        }
        return;
      }
      
      pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 4),
        ),
      );
      if (pos != null) {
        if (mounted) {
          setState(() {
            _initialPosition = LatLng(pos!.latitude, pos.longitude);
            _isLoadingInitialLocation = false;
          });
        }
        return;
      }
    } catch (_) {}
    
    _setFallbackLocation();
  }

  void _setFallbackLocation() {
    if (mounted) {
      setState(() {
        _initialPosition = const LatLng(39.8283, -98.5795);
        _isLoadingInitialLocation = false;
      });
    }
  }

  void _updatePickingState() {
    if (_ctrl.endLat.value.isNotEmpty) {
      _pickingState = 2;
    } else if (_ctrl.startLat.value.isNotEmpty) {
      _pickingState = 1;
    } else {
      _pickingState = 0;
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingInitialLocation) {
      return Container(
        height: widget.isFullScreen ? double.infinity : 300.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF0F173A),
          borderRadius: BorderRadius.circular(4.r),
          border: Border.all(color: Colors.white10),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Color(0xFFF58842)),
        ),
      );
    }

    return Container(
      height: widget.isFullScreen ? double.infinity : 300.h,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.r),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          MapLibreMap(
            styleString:
                // 'https://api.maptiler.com/maps/openstreetmap/style.json?key=N2YLLvhtmoQzVSf9VfF9',
                'https://api.maptiler.com/maps/streets-v2/style.json?key=N2YLLvhtmoQzVSf9VfF9',
            initialCameraPosition: CameraPosition(
              target: _initialPosition!,
              zoom: 14.0,
            ),
            myLocationEnabled: true,
            compassEnabled: false,
            zoomGesturesEnabled: true,
            scrollGesturesEnabled: true,
            rotateGesturesEnabled: true,
            tiltGesturesEnabled: true,
            trackCameraPosition: true,
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
              Factory<OneSequenceGestureRecognizer>(
                () => EagerGestureRecognizer(),
              ),
            },
            onMapCreated: (controller) {
              mapController = controller;
              mapController!.onFeatureDrag.add(_onFeatureDrag);
            },
            onStyleLoadedCallback: _onStyleLoaded,
            // Removed onMapClick for center pin placement
          ),
          if (_pickingState < 2)
            Center(
              child: Container(
                width: 50.0,
                height: 50.0,
                decoration: BoxDecoration(
                  color: _pickingState == 0 ? const Color(0xFF1BA345) : const Color(0xFFFF0000),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4.0),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 6.0, offset: Offset(0, 3)),
                  ],
                ),
                child: Center(
                  child: Text(
                    _pickingState == 0 ? 'S' : 'E',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28.0,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Lato',
                    ),
                  ),
                ),
              ),
            ),
          if (_pickingState < 2)
            Positioned(
              bottom: 20.h,
              left: 0,
              right: 0,
              child: Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF58842),
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  onPressed: _confirmCenterLocation,
                  child: Text(
                    _pickingState == 0 ? 'Confirm Start' : 'Confirm End',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          if (_pickingState == 2)
            Positioned(
              bottom: 20.h,
              left: 20.w,
              child: InkWell(
                onTap: _resetMap,
                child: Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4.r),
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                  ),
                  child: const Icon(Icons.refresh, color: Colors.black87),
                ),
              ),
            ),
          Positioned(
            top: 10.h,
            right: 10.w,
            child: InkWell(
              onTap: () async {
                if (widget.isFullScreen) {
                  Get.back();
                } else {
                  await Get.to(
                    () => Scaffold(
                      body: SafeArea(
                        child: AfterConfirmMap(isFullScreen: true),
                      ),
                    ),
                  );
                  _syncMarkersFromController();
                }
              },
              child: Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4.r),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                    )
                  ],
                ),
                child: Icon(
                  widget.isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _syncMarkersFromController() async {
    if (mapController == null) return;

    LatLng? startCoords;
    LatLng? endCoords;

    if (_ctrl.startLat.value.isNotEmpty && _ctrl.startLng.value.isNotEmpty) {
      double lat = double.tryParse(_ctrl.startLat.value) ?? 0.0;
      double lng = double.tryParse(_ctrl.startLng.value) ?? 0.0;
      if (lat != 0.0 && lng != 0.0) {
        startCoords = LatLng(lat, lng);
      }
    }

    if (_ctrl.endLat.value.isNotEmpty && _ctrl.endLng.value.isNotEmpty) {
      double lat = double.tryParse(_ctrl.endLat.value) ?? 0.0;
      double lng = double.tryParse(_ctrl.endLng.value) ?? 0.0;
      if (lat != 0.0 && lng != 0.0) {
        endCoords = LatLng(lat, lng);
      }
    }

    // 1. Fetch Route FIRST to prevent map flickering during network request
    List<LatLng>? routeGeometry;
    if (startCoords != null && endCoords != null) {
      routeGeometry = await _fetchOsrmRoute([startCoords, endCoords]);
    }

    // 2. Sync Start Symbol
    if (startCoords == null) {
      if (_startSymbol != null) {
        try {
          await mapController!.removeSymbol(_startSymbol!);
        } catch (_) {}
        _startSymbol = null;
      }
    } else {
      if (_startSymbol != null) {
        try {
          await mapController!.updateSymbol(
            _startSymbol!,
            SymbolOptions(geometry: startCoords),
          );
        } catch (_) {
          try {
            _startSymbol = await mapController!.addSymbol(
              SymbolOptions(
                geometry: startCoords,
                iconImage: 'start-icon',
                iconSize: 1.0,
                iconAnchor: 'center',
                draggable: true,
              ),
            );
          } catch (_) {}
        }
      } else {
        try {
          _startSymbol = await mapController!.addSymbol(
            SymbolOptions(
              geometry: startCoords,
              iconImage: 'start-icon',
              iconSize: 1.0,
              iconAnchor: 'center',
              draggable: true,
            ),
          );
        } catch (_) {}
      }
    }

    // 3. Sync End Symbol
    if (endCoords == null) {
      if (_endSymbol != null) {
        try {
          await mapController!.removeSymbol(_endSymbol!);
        } catch (_) {}
        _endSymbol = null;
      }
    } else {
      if (_endSymbol != null) {
        try {
          await mapController!.updateSymbol(
            _endSymbol!,
            SymbolOptions(geometry: endCoords),
          );
        } catch (_) {
          try {
            _endSymbol = await mapController!.addSymbol(
              SymbolOptions(
                geometry: endCoords,
                iconImage: 'end-icon',
                iconSize: 1.0,
                iconAnchor: 'center',
                draggable: true,
              ),
            );
          } catch (_) {}
        }
      } else {
        try {
          _endSymbol = await mapController!.addSymbol(
            SymbolOptions(
              geometry: endCoords,
              iconImage: 'end-icon',
              iconSize: 1.0,
              iconAnchor: 'center',
              draggable: true,
            ),
          );
        } catch (_) {}
      }
    }

    // 4. Sync Route Line
    if (routeGeometry == null) {
      if (_routeLine != null) {
        try {
          await mapController!.removeLine(_routeLine!);
        } catch (_) {}
        _routeLine = null;
      }
    } else {
      if (_routeLine != null) {
        try {
          await mapController!.updateLine(
            _routeLine!,
            LineOptions(geometry: routeGeometry),
          );
        } catch (_) {
          try {
            _routeLine = await mapController!.addLine(
              LineOptions(
                geometry: routeGeometry,
                lineColor: '#F58842',
                lineWidth: 5.0,
                lineOpacity: 0.4,
                lineJoin: 'round',
              ),
            );
          } catch (_) {}
        }
      } else {
        try {
          _routeLine = await mapController!.addLine(
            LineOptions(
              geometry: routeGeometry,
              lineColor: '#F58842',
              lineWidth: 5.0,
              lineOpacity: 0.4,
              lineJoin: 'round',
            ),
          );
        } catch (_) {}
      }
    }

    if (startCoords != null && endCoords != null) {
      await _fitBounds([startCoords, endCoords]);
    } else if (startCoords != null) {
      await mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: startCoords, zoom: 14.0),
        ),
      );
    }
    
    _updatePickingState();
  }

  Future<void> _onStyleLoaded() async {
    if (mapController == null) return;

    if (_ctrl.startLat.value.isEmpty && _ctrl.endLat.value.isEmpty) {
      try {
        var perm = await Geolocator.checkPermission();
        if (perm == LocationPermission.denied) {
          perm = await Geolocator.requestPermission();
        }
        if (perm == LocationPermission.always || perm == LocationPermission.whileInUse) {
          final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
          await mapController!.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(target: LatLng(pos.latitude, pos.longitude), zoom: 14.0),
          ));
        }
      } catch (_) {}
    }

    await MapIconUtil.loadStartEndIcons(mapController);

    await _syncMarkersFromController();
  }

  Future<void> _confirmCenterLocation() async {
    if (mapController == null) return;
    final cameraPos = mapController!.cameraPosition;
    if (cameraPos == null) return;
    await _handleLocationSelection(cameraPos.target);
  }

  Future<void> _handleLocationSelection(LatLng coordinates) async {
    if (mapController == null) return;

    // Determine location name
    String locationName = 'Unknown Location';
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          coordinates.latitude, coordinates.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        locationName = place.locality ??
            place.subAdministrativeArea ??
            place.administrativeArea ??
            place.country ??
            'Unknown Location';
      }
    } catch (e) {
      debugPrint('Geocoding error: $e');
    }

    if (_pickingState == 0) {
      // Forcefully clear any stray ghost symbols/lines to ensure a clean slate
      try {
        await mapController!.clearSymbols();
        await mapController!.clearLines();
      } catch (e) {
        debugPrint('Error clearing map: $e');
      }

      // Set Start Location
      _startSymbol = await mapController!.addSymbol(
        SymbolOptions(
          geometry: coordinates,
          iconImage: 'start-icon',
          iconSize: 1.0,
          iconAnchor: 'center',
          draggable: true,
        ),
      );
      _ctrl.startLat.value = coordinates.latitude.toString();
      _ctrl.startLng.value = coordinates.longitude.toString();
      _ctrl.startLocation.value = locationName;
      _updatePickingState();
    } else if (_pickingState == 1) {
      // Set End Location
      _endSymbol = await mapController!.addSymbol(
        SymbolOptions(
          geometry: coordinates,
          iconImage: 'end-icon',
          iconSize: 1.0,
          iconAnchor: 'center',
          draggable: true,
        ),
      );

      // Draw Polyline
      final routeGeometry = await _fetchOsrmRoute([
        _startSymbol!.options.geometry!,
        coordinates,
      ]);

      _ctrl.endLat.value = coordinates.latitude.toString();
      _ctrl.endLng.value = coordinates.longitude.toString();
      _ctrl.endLocation.value = locationName;

      _updatePickingState();
      
      // Full re-sync to ensure correct layer ordering (Fill -> Line -> Symbol)
      await _syncMarkersFromController();
    }
  }

  void _resetMap() async {
    try {
      await mapController!.clearSymbols();
      await mapController!.clearLines();
    } catch (e) {
      debugPrint('Error clearing map: $e');
    }
    _startSymbol = null;
    _endSymbol = null;
    _routeLine = null;
    _ctrl.startLat.value = '';
    _ctrl.startLng.value = '';
    _ctrl.startLocation.value = '';
    _ctrl.endLat.value = '';
    _ctrl.endLng.value = '';
    _ctrl.endLocation.value = '';
    
    _updatePickingState();
  }

  void _onFeatureDrag(
    Point<double> point,
    LatLng origin,
    LatLng current,
    LatLng delta,
    String id,
    dynamic annotation,
    DragEventType eventType,
  ) async {
    if (eventType == DragEventType.start && annotation is Symbol) {
      await mapController!.updateSymbol(
          annotation, const SymbolOptions(iconSize: 2.5, iconOffset: Offset(0, 0)));
      return;
    }

    if (eventType != DragEventType.end) return;

    if (annotation is Symbol) {
      await mapController!.updateSymbol(
          annotation, const SymbolOptions(iconSize: 1.0, iconOffset: Offset(0, 0)));
    }

    final LatLng newCoords = current;

    // 1. Immediately update coordinates to sync map route line
    if (_startSymbol != null && id == _startSymbol!.id) {
      _ctrl.startLat.value = newCoords.latitude.toString();
      _ctrl.startLng.value = newCoords.longitude.toString();
    } else if (_endSymbol != null && id == _endSymbol!.id) {
      _ctrl.endLat.value = newCoords.latitude.toString();
      _ctrl.endLng.value = newCoords.longitude.toString();
    }

    // Trigger map redraw immediately (OSRM fetch + updates symbols/lines in-place)
    final syncFuture = _syncMarkersFromController();

    // 2. Fetch the geocoded address asynchronously in the background so it doesn't block responsiveness
    Future.microtask(() async {
      String locationName = 'Unknown Location';
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
            newCoords.latitude, newCoords.longitude);
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks.first;
          locationName = place.locality ??
              place.subAdministrativeArea ??
              place.administrativeArea ??
              place.country ??
              'Unknown Location';
        }
      } catch (e) {
        debugPrint('Geocoding error: $e');
      }

      if (_startSymbol != null && id == _startSymbol!.id) {
        _ctrl.startLocation.value = locationName;
      } else if (_endSymbol != null && id == _endSymbol!.id) {
        _ctrl.endLocation.value = locationName;
      }
    });

    await syncFuture;
  }

  Future<void> _fitBounds(List<LatLng> points) async {
    if (mapController == null || points.isEmpty) return;

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (var point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    await mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        left: 50,
        right: 50,
        top: 50,
        bottom: 50,
      ),
      duration: const Duration(milliseconds: 1000), // Smooth animation
    );
  }

  static const String _osrmBase =
      'https://router.project-osrm.org/route/v1/driving';

  Future<List<LatLng>> _fetchOsrmRoute(List<LatLng> points) async {
    final coordStr =
        points.map((p) => '${p.longitude},${p.latitude}').join(';');
    final uri =
        Uri.parse('$_osrmBase/$coordStr?overview=full&geometries=geojson');

    for (int attempt = 0; attempt <= 2; attempt++) {
      try {
        final response = await http.get(uri).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final routes = data['routes'] as List?;
          if (routes != null && routes.isNotEmpty) {
            final routeData = routes[0] as Map<String, dynamic>;
            if (routeData['distance'] != null) {
              _routeDistanceMeters = (routeData['distance'] as num).toDouble();
            }
            final geometry = routeData['geometry'] as Map<String, dynamic>;
            final coords = geometry['coordinates'] as List;
            return coords
                .map<LatLng>((c) =>
                    LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()))
                .toList();
          }
        }
      } catch (e) {
        debugPrint('OSRM attempt ${attempt + 1} failed: $e');
        if (attempt < 2) {
          await Future.delayed(Duration(milliseconds: 500 * (attempt + 1)));
        }
      }
    }

    return List.from(points);
  }

}
