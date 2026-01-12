import 'package:velo_map_app/core/network/api_client.dart';
import 'package:velo_map_app/features/routes/data/datasources/routes_local_datasource.dart';
import 'package:velo_map_app/features/routes/data/datasources/routes_remote_datasource.dart';
import 'package:velo_map_app/features/routes/data/repositories/routes_repository.dart';

class AppDependencies {
  late final RoutesRepository routesRepository;

  AppDependencies() {
    final httpClient = Http();

    final remote = RoutesRemoteDataSourceImpl(
      client: httpClient,
      baseUrl: 'https://api.example.com/routes',
    );

    final local = RoutesLocalDataSourceImpl();

    routesRepository = RoutesRepository(remote: remote, local: local);
  }
}
