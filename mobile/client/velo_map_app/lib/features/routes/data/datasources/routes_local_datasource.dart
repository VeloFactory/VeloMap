import 'package:velo_map_app/features/routes/data/models/route_dto.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle, AssetManifest;

abstract class RoutesLocalDatasource {
  Future<List<RouteDto>> getRoutes();
}

class RoutesLocalDataSourceImpl implements RoutesLocalDatasource {
  RoutesLocalDataSourceImpl();

  @override
  Future<List<RouteDto>> getRoutes() async {
    final manifest1 = await AssetManifest.loadFromAssetBundle(rootBundle);
    final assets = manifest1.listAssets();

    final files = assets
        .where((p) => p.startsWith('assets/routes/') && p.endsWith('.json'))
        .toList();

    final routes = <RouteDto>[];

    int numFromPath(String p) =>
        int.tryParse(p.split('/').last.replaceAll('.json', '')) ?? 0;

    files.sort((a, b) => numFromPath(a).compareTo(numFromPath(b)));

    for (final path in files) {
      final jsonStr = await rootBundle.loadString(path);
      final decoded = jsonDecode(jsonStr);

      // если в файле один объект Route
      if (decoded is Map<String, dynamic>) {
        routes.add(RouteDto.fromJson(decoded));
      }
      // если в файле массив Route-ов
      else if (decoded is List) {
        routes.addAll(
          decoded.cast<Map<String, dynamic>>().map((e) => RouteDto.fromJson(e)),
        );
      } else {
        throw FormatException('Unsupported JSON format in $path');
      }
    }

    return routes;
  }
}
