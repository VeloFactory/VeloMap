import 'package:velo_map_app/features/routes/domain/models/route_model.dart';

/// Abstract repository interface for route data.
/// This allows easy swapping between local and remote data sources.
abstract class RouteRepository {
  /// Fetches all available routes
  Future<List<RouteModel>> getRoutes();

  /// Fetches a single route by ID
  Future<RouteModel?> getRouteById(String id);
}
