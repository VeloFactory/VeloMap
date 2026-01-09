import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:velo_map_app/errors/bloc_observable.dart';
import 'app/app.dart';

final application = GlobalKey();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dir = await getApplicationDocumentsDirectory();
  final storage = await HydratedStorage.build(
    storageDirectory: HydratedStorageDirectory(dir.path),
  );
  HydratedBloc.storage = storage;

  Bloc.observer = BlocObservable();

  runApp(
    // MultiBlocProvider(
    //   providers: [],
    //   child: App(key: application),
    // ),
    App(key: application),
  );
}
