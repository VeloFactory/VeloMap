import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:velo_map_app/features/routes/domain/models/route_model.dart';

/// Data source that reads route data from local GeoJSON assets.
/// Stage 1: Uses bundled static files.
/// Stage 2: Will be replaced with RemoteRouteDatasource for API calls.
class LocalRouteDatasource {
  /// List of asset paths for bundled GeoJSON route files
  static const List<String> _routeAssets = [
    'assets/routes/coastal_trail.geojson',
    'assets/routes/mountain_loop.geojson',
    'assets/routes/city_circuit.geojson',
    'assets/routes/EuroVelo6.geojson'
  ];

  /// Fetches all routes from local GeoJSON assets
  Future<List<RouteModel>> fetchRoutes() async {
    final routes = <RouteModel>[];

    for (final assetPath in _routeAssets) {
      try {
        final jsonString = await rootBundle.loadString(assetPath);
        final geoJson = json.decode(jsonString) as Map<String, dynamic>;
        final route = RouteModel.fromGeoJson(geoJson);
        routes.add(route);
      } catch (e) {
        // Log error but continue loading other routes
        print('Error loading route from $assetPath: $e');
      }
    }

    return routes;
  }

  /// Fetches a single route by ID from local assets
  Future<RouteModel?> fetchRouteById(String id) async {
    final routes = await fetchRoutes();
    try {
      return routes.firstWhere((route) => route.id == id);
    } catch (_) {
      return null;
    }
  }
}
