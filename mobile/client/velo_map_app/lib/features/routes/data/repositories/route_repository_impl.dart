import 'package:velo_map_app/features/routes/data/datasources/local_route_datasource.dart';
import 'package:velo_map_app/features/routes/domain/models/route_model.dart';
import 'package:velo_map_app/features/routes/domain/repositories/route_repository.dart';

/// Implementation of RouteRepository using local data source.
/// To switch to remote API in Stage 2:
/// 1. Create RemoteRouteDatasource
/// 2. Replace LocalRouteDatasource with RemoteRouteDatasource in constructor
class RouteRepositoryImpl implements RouteRepository {
  final LocalRouteDatasource _datasource;

  RouteRepositoryImpl({LocalRouteDatasource? datasource})
      : _datasource = datasource ?? LocalRouteDatasource();

  @override
  Future<List<RouteModel>> getRoutes() async {
    return _datasource.fetchRoutes();
  }

  @override
  Future<RouteModel?> getRouteById(String id) async {
    return _datasource.fetchRouteById(id);
  }
}
