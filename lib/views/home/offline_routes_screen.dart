import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:right_routes/core/constants/services/offline_route_service.dart';
import 'package:right_routes/utils/colors.dart';
import 'package:right_routes/views/home/create_new_routes/drive_screen/drive_screen.dart';
import '../../utils/colors.dart';

class OfflineRoutesScreen extends StatefulWidget {
  const OfflineRoutesScreen({Key? key}) : super(key: key);

  @override
  _OfflineRoutesScreenState createState() => _OfflineRoutesScreenState();
}

class _OfflineRoutesScreenState extends State<OfflineRoutesScreen> {
  List<Map<String, dynamic>> _offlineRoutes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRoutes();
  }

  Future<void> _loadRoutes() async {
    setState(() => _isLoading = true);
    final routes = await OfflineRouteService.getOfflineRoutes();
    setState(() {
      _offlineRoutes = routes;
      _isLoading = false;
    });
  }

  Future<void> _deleteRoute(String routeId) async {
    final success = await OfflineRouteService.deleteOfflineRoute(routeId);
    if (success) {
      _loadRoutes();
      Get.snackbar('Deleted', 'Offline route removed.',
          backgroundColor: Color(0xFF0B1129), colorText: Colors.white);
    }
  }

  void _openOfflineDriveMode(Map<String, dynamic> routeData) {
    List<dynamic> wpList = routeData['waypoints'] ?? [];
    List<LatLng> parsedWaypoints = wpList.map((wp) {
      return LatLng(wp['lat'] as double, wp['lng'] as double);
    }).toList();

    Get.to(() => const DriveRouteMap(), arguments: {
      'routeId': routeData['routeId'],
      'routePoints': parsedWaypoints,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0B1129),
      appBar: AppBar(
        backgroundColor: Color(0xFF0B1129),
        title: const Text('Offline Saved Routes',
            style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.orange))
          : _offlineRoutes.isEmpty
              ? Center(
                  child: Text(
                    'No offline routes saved yet.',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _offlineRoutes.length,
                  itemBuilder: (context, index) {
                    final route = _offlineRoutes[index];
                    final dt = DateTime.fromMillisecondsSinceEpoch(
                        route['downloadDate'] as int);
                    final dateStr =
                        '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';

                    return Card(
                      color: Color(0xFF0B1129),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                            color: AppColors.white.withValues(alpha: 0.2)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        title: Text(
                          route['routeName'] ?? 'Unknown Route',
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Saved on: $dateStr',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6)),
                        ),
                        trailing: IconButton(
                          icon:
                              const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () =>
                              _deleteRoute(route['routeId'] as String),
                        ),
                        onTap: () => _openOfflineDriveMode(route),
                      ),
                    );
                  },
                ),
    );
  }
}
