import 'package:go_router/go_router.dart';
import 'package:velo_map_app/features/navigation/navigation.dart';
import 'package:velo_map_app/features/routes/routes.dart';

final router = GoRouter(
  initialLocation: '/routes',
  routes: [
    GoRoute(path: '/routes', builder: (context, state) => const Routes()),
    GoRoute(
      path: '/navigation',
      builder: (context, state) => const Navigation(),
    ),
  ],
);
