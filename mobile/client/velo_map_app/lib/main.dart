import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:velo_map_app/core/errors/bloc_observable.dart';
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

  await dotenv.load(fileName: '.env');

  final key = dotenv.env['MAPBOX_KEY'] ?? 'NO_KEY';
  MapboxOptions.setAccessToken(key);

  // debugPaintSizeEnabled = false;
  runApp(App(key: application));
}
