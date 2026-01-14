import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:velo_map_app/features/routes/data/models/route_dto.dart';

/// Data source that reads route data from local GeoJSON assets.
/// Stage 1: Uses bundled static files.
/// Stage 2: Will be replaced with RemoteRouteDatasource for API calls.
class RouteLocalDatasource {
  /// List of asset paths for bundled GeoJSON route files
  Future<List<RouteDto>> fetchRoutes() async {
    final manifest1 = await AssetManifest.loadFromAssetBundle(rootBundle);
    final assets = manifest1.listAssets();

    final files = assets
        .where(
          (p) =>
              p.startsWith('assets/routes/geojson') && p.endsWith('.geojson'),
        )
        .toList();

    final routes = <RouteDto>[];

    int numFromPath(String p) =>
        int.tryParse(p.split('/').last.replaceAll('.json', '')) ?? 0;

    files.sort((a, b) => numFromPath(a).compareTo(numFromPath(b)));

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

  /// Fetches a single route by ID from local assets
  Future<RouteDto?> fetchRouteById(String id) async {
    final routes = await fetchRoutes();
    try {
      return routes.firstWhere((route) => route.id == id);
    } catch (_) {
      return null;
    }
  }
}
