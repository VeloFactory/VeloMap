import 'package:velo_map_app/features/routes/domain/entities/route_entity.dart';
import 'package:velo_map_app/features/routes/domain/entities/route_stage_entity.dart';

/// A single leg of a planned route — travel on one EuroVelo route between two cities
class RoutePlanSegment {
  final RouteEntity route;
  final String fromCity;
  final String toCity;
  final List<String> cities;
  final List<RouteStageEntity> stages;
  final List<List<double>> coordinates;

  const RoutePlanSegment({
    required this.route,
    required this.fromCity,
    required this.toCity,
    required this.cities,
    required this.stages,
    required this.coordinates,
  });

  double get distanceKm {
    double total = 0;
    for (final stage in stages) {
      total += stage.distanceKm;
    }
    return total;
  }

  double get elevationGain {
    double total = 0;
    for (final stage in stages) {
      total += stage.elevationGain;
    }
    return total;
  }
}

/// One complete plan variant from start to end (may involve multiple EuroVelo routes)
class RoutePlanVariant {
  final List<RoutePlanSegment> segments;

  const RoutePlanVariant({required this.segments});

  double get totalDistanceKm {
    double total = 0;
    for (final seg in segments) {
      total += seg.distanceKm;
    }
    return total;
  }

  double get totalElevationGain {
    double total = 0;
    for (final seg in segments) {
      total += seg.elevationGain;
    }
    return total;
  }

  /// Human-readable summary: "EuroVelo 1 → EuroVelo 13"
  String get routeSummary {
    return segments.map((s) => s.route.name).join(' → ');
  }

  /// Convert this variant into a RouteEntity so it can be displayed
  /// in the existing route list, selected, shown on map, exported as GPX.
  RouteEntity toRouteEntity({required int variantIndex}) {
    final from = segments.first.fromCity;
    final to = segments.last.toCity;

    // Merge all coordinates
    final allCoords = <List<double>>[];
    for (final seg in segments) {
      allCoords.addAll(seg.coordinates);
    }

    // Merge all stages
    final allStages = <RouteStageEntity>[];
    int stageNum = 1;
    for (final seg in segments) {
      for (final stage in seg.stages) {
        allStages.add(RouteStageEntity(
          stage: stageNum++,
          name: stage.name,
          description: '${seg.route.name} • ${stage.description}',
          distanceKm: stage.distanceKm,
          elevationGain: stage.elevationGain,
          difficulty: stage.difficulty,
          coordinates: stage.coordinates,
        ));
      }
    }

    // Merge all cities
    final allCities = <String>[];
    for (final seg in segments) {
      for (final city in seg.cities) {
        if (allCities.isEmpty || allCities.last != city) {
          allCities.add(city);
        }
      }
    }

    // Use color of the first route segment
    final color = segments.isNotEmpty ? segments.first.route.colorValue : 0xFF2196F3;

    final totalDist = totalDistanceKm;
    final totalElev = totalElevationGain;

    // Build description showing the route chain
    final viaRoutes = segments.map((s) => s.route.name).toSet().join(', ');
    final description = segments.length == 1
        ? 'Direct via ${segments.first.route.name}'
        : 'Via $viaRoutes';

    return RouteEntity(
      id: 'plan_${from}_${to}_v$variantIndex',
      name: '$from → $to',
      description: description,
      distanceKm: totalDist,
      elevationGainM: totalElev,
      difficulty: _worstDifficulty(allStages),
      routeNumber: 0,
      colorValue: color,
      coordinates: allCoords,
      stages: allStages,
      cities: allCities,
      routeDescription: _buildRouteDescription(),
      fullName: '$from → $to (Route Plan)',
    );
  }

  String _worstDifficulty(List<RouteStageEntity> stages) {
    const order = {'easy': 0, 'moderate': 1, 'hard': 2};
    String worst = 'easy';
    int worstScore = -1;
    for (final s in stages) {
      final score = order[s.difficulty] ?? 1;
      if (score > worstScore) {
        worstScore = score;
        worst = s.difficulty;
      }
    }
    return worst;
  }

  String _buildRouteDescription() {
    final buf = StringBuffer();
    buf.writeln('Planned cycling route\n');
    for (int i = 0; i < segments.length; i++) {
      final seg = segments[i];
      buf.writeln(
        '${i + 1}. ${seg.route.name}: ${seg.fromCity} → ${seg.toCity} '
        '(${seg.distanceKm.toStringAsFixed(1)} km)',
      );
      if (i < segments.length - 1) {
        buf.writeln('   Transfer at ${seg.toCity}');
      }
    }
    buf.writeln('\nTotal: ${totalDistanceKm.toStringAsFixed(1)} km');
    return buf.toString();
  }
}