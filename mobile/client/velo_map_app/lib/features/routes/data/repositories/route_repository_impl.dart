import 'package:dartz/dartz.dart';
import 'package:velo_map_app/core/errors/data_exceptions.dart';
import 'package:velo_map_app/core/errors/failure.dart';
import 'package:velo_map_app/features/routes/data/datasources/routes_local_datasource.dart';
import 'package:velo_map_app/features/routes/domain/entities/route_entity.dart';

abstract class RouteRepository {
  /// Fetches all available routes
  Future<Either<Failure, List<RouteEntity>>> getRoutes();

  /// Fetches a single route by ID
  Future<Either<Failure, RouteEntity?>> getRouteById(String id);
}

/// Implementation of RouteRepository using local data source.
/// To switch to remote API in Stage 2:
/// 1. Create RemoteRouteDatasource
/// 2. Replace LocalRouteDatasource with RemoteRouteDatasource in constructor
class RouteRepositoryImpl implements RouteRepository {
  final RouteLocalDatasource _datasource;

  RouteRepositoryImpl({RouteLocalDatasource? datasource})
    : _datasource = datasource ?? RouteLocalDatasource();

  @override
  Future<Either<Failure, List<RouteEntity>>> getRoutes() async {
    try {
      final dtos = await _datasource.fetchRoutes();
      final entities = dtos.map((e) => e.toEntity()).toList(growable: false);

      return Right(entities);
    } on InvalidResponseException catch (e) {
      return Left(UnknownFailure(e.message));
    } catch (_) {
      return const Left(UnknownFailure('Unknown error'));
    }
  }

  @override
  Future<Either<Failure, RouteEntity?>> getRouteById(String id) async {
    try {
      final dto = await _datasource.fetchRouteById(id);

      if (dto == null) {
        return const Left(UnknownFailure('Route not found'));
      }

      return Right(dto.toEntity());
    } on InvalidResponseException catch (e) {
      return Left(UnknownFailure(e.message));
    } catch (_) {
      return const Left(UnknownFailure('Unknown error'));
    }
  }
}
