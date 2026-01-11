import 'package:velo_map_app/core/models/geo_point.dart';
import 'package:velo_map_app/features/routes/models/route_metrics.dart';

enum RouteDifficulty { easy, medium, hard }

class RouteCard {
  final String id;
  final String name;
  final String? description;
  final RouteDifficulty? difficulty;

  final int countries;
  final List<GeoPoint> path;
  final RouteMetrics metrics;

  final String? icon;
  final List<String> imageUrls;
  final List<RouteCard> subRoutes;

  const RouteCard({
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
