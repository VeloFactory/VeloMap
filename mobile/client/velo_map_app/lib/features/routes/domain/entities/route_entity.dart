import 'package:velo_map_app/core/entities/geo_point.dart';
import 'package:velo_map_app/features/routes/domain/entities/route_metrics_entity.dart';

enum RouteDifficulty { easy, medium, hard }

class RouteEntity {
  final String id;
  final String name;
  final String? description;
  final RouteDifficulty? difficulty;

  final int countries;
  final List<GeoPoint> path;
  final RouteMetricsEntity metrics;

  final String? icon;
  final List<String> imageUrls;
  final List<RouteEntity> subRoutes;

  const RouteEntity({
    required this.id,
    required this.name,
    this.description,
    this.difficulty,
    required this.countries,
    required this.path,
    required this.metrics,
    this.icon,
    this.imageUrls = const [],
    this.subRoutes = const [],
  });

  bool get hasSubRoutes => subRoutes.isNotEmpty;
}
