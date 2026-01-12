import 'package:flutter/material.dart';
import 'package:velo_map_app/app/dependencies.dart';
import 'package:velo_map_app/app/router.dart';

class App extends StatefulWidget {
  final AppDependencies deps;
  const App({super.key, required, required this.deps});

  @override
  State<StatefulWidget> createState() => AppState();
}

class AppState extends State<App> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      color: Colors.white,
      routerConfig: createRouter(widget.deps),
    );
  }
}
