import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:velo_map_app/features/routes/data/models/route_dto.dart';

/// Data source that reads route data from local GeoJSON assets.
/// Stage 1: Uses bundled static files.
/// Stage 2: Will be replaced with RemoteRouteDatasource for API calls.
class RouteLocalDatasource {
  List<RouteDto>? _routesCache;
  Map<String, RouteDto>? _routesByIdCache;
  Future<List<RouteDto>>? _loadFuture;

  Future<List<RouteDto>> _loadRoutes() async {
    final files = await _routeFiles();
    final routes = <RouteDto>[];

    for (final path in files) {
      final jsonStr = await rootBundle.loadString(path);
      final decoded = jsonDecode(jsonStr);

      if (decoded is Map<String, dynamic>) {
        routes.add(RouteDto.fromGeoJson(decoded));
      } else {
        throw FormatException('Unsupported JSON format in $path');
      }
    }

    return routes;
  }

  Future<List<String>> _routeFiles() async {
    const allowedRoutes = {6, 9, 14, 1, 4};

    final manifest1 = await AssetManifest.loadFromAssetBundle(rootBundle);
    final assets = manifest1.listAssets();

    int numFromPath(String path) {
      final name = path.split('/').last.split('.').first;
      final match = RegExp(r'\d+').firstMatch(name);
      return match != null ? int.parse(match.group(0)!) : 0x7fffffff;
    }

    final files = assets
        .where(
          (p) =>
              p.startsWith('assets/routes/geojson') &&
              p.endsWith('.geojson') &&
              allowedRoutes.contains(numFromPath(p)),
        )
        .toList();

    files.sort((a, b) => numFromPath(a).compareTo(numFromPath(b)));
    return files;
  }

  /// List of asset paths for bundled GeoJSON route files
  Future<List<RouteDto>> fetchRoutes() async {
    if (_routesCache != null) return _routesCache!;
    if (_loadFuture != null) return _loadFuture!;

    _loadFuture = _loadRoutes();
    try {
      final routes = await _loadFuture!;
      _routesCache = routes;
      return routes;
    } finally {
      _loadFuture = null;
    }
  }

  /// Fetches a single route by ID from local assets
  Future<RouteDto?> fetchRouteById(String id) async {
    if (_routesByIdCache == null) {
      final routes = await fetchRoutes();
      _routesByIdCache = {for (final route in routes) route.id: route};
    }

    return _routesByIdCache![id];
  }
}
