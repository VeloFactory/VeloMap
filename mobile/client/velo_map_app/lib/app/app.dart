import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:velo_map_app/app/router.dart';
import 'package:velo_map_app/core/theme/app_theme.dart';
import 'package:velo_map_app/features/routes/data/repositories/route_repository_impl.dart';
import 'package:velo_map_app/features/routes/presentation/bloc/routes_bloc.dart';
import 'package:velo_map_app/features/routes/presentation/bloc/routes_event.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<RouteRepository>(create: (_) => RouteRepositoryImpl()),
      ],
      child: Builder(
        builder: (context) {
          return MultiBlocProvider(
            providers: [
              BlocProvider<RoutesBloc>(
                create: (context) =>
                    RoutesBloc(repository: context.read<RouteRepository>())
                      ..add(const RoutesEvent.load()),
              ),
            ],
            child: MaterialApp.router(
              title: 'VeloMap',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light(),
              darkTheme: AppTheme.dark(),
              themeMode: ThemeMode.system,
              routerConfig: router,
            ),
          );
        },
      ),
    );
  }
}
