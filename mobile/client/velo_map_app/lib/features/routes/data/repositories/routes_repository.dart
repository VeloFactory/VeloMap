import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:velo_map_app/errors/failure.dart';
import 'package:velo_map_app/features/routes/data/datasources/routes_local_datasource.dart';
import '../../../../core/network/data_exceptions.dart';
import '../../domain/entities/route_entity.dart';
import '../datasources/routes_remote_datasource.dart';

class RoutesRepository {
  final RoutesRemoteDataSource remote;
  final RoutesLocalDataSourceImpl local;

  RoutesRepository({required this.remote, required this.local});

  Future<Either<Failure, List<RouteEntity>>> getRoutes() async {
    try {
      // final dtos = await remote.getRoutes();
      // final entities = dtos.map((e) => e.toEntity()).toList(growable: false);

      final dtos = await local.getRoutes();
      final entities = dtos.map((e) => e.toEntity()).toList(growable: false);

      return Right(entities);
    } on RequestTimeoutException {
      return const Left(NetworkFailure('Request timed out'));
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection'));
    } on ApiException catch (e) {
      if (e.statusCode >= 500) {
        return Left(ServerFailure('Server error (${e.statusCode})'));
      }
      return Left(ServerFailure('Request failed (${e.statusCode})'));
    } on InvalidResponseException catch (e) {
      return Left(UnknownFailure(e.message));
    } catch (_) {
      return const Left(UnknownFailure('Unknown error'));
    }
  }
}
