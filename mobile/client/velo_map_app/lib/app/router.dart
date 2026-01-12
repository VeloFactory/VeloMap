import 'package:go_router/go_router.dart';
import 'package:velo_map_app/app/dependencies.dart';
import 'package:velo_map_app/features/navigation/presentation/pages/navigation.dart';
import 'package:velo_map_app/features/routes/presentation/pages/routes.dart';

GoRouter createRouter(AppDependencies deps) {
  return GoRouter(
    initialLocation: '/routes',
    routes: [
      GoRoute(
        path: '/routes',
        builder: (context, state) =>
            Routes(routesRepository: deps.routesRepository),
      ),
      GoRoute(
        path: '/navigation',
        builder: (context, state) => const Navigation(),
      ),
    ],
  );
}
