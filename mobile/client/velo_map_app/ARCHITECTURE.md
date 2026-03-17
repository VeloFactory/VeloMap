# VeloMap Architecture Guide

Welcome to VeloMap! This guide explains the project architecture, data flow, and codebase organization.

## 📋 Table of Contents

1. [Project Overview](#project-overview)
2. [Getting Started](#getting-started)
3. [Architecture Overview](#architecture-overview)
4. [Folder Structure](#folder-structure)
5. [State Management](#state-management)
6. [Data Flow](#data-flow)
7. [Feature Modules](#feature-modules)
8. [Key Components](#key-components)
9. [Code Generation](#code-generation)
10. [Adding New Features](#adding-new-features)

---

## 🎯 Project Overview

**VeloMap** is a Flutter mobile application for exploring EuroVelo cycling routes across Europe. The app displays routes on an interactive Mapbox map with features like:

- 🗺️ Interactive map with EuroVelo cycling routes
- 🔍 Search routes by city
- 📍 User location tracking
- 🏨 POI layer toggles (hotels, restaurants, campsites) with tap-to-info
- 📊 Route details with stages, distance, and elevation
- 🧭 Stage status tracking (planned, in-progress, completed)

### Tech Stack

| Technology | Purpose |
|------------|---------|
| Flutter 3.10+ | Cross-platform UI framework |
| Mapbox Maps Flutter | Interactive map rendering |
| flutter_bloc | State management (BLoC pattern) |
| Freezed | Immutable classes & union types |
| Dartz | Functional programming (Either type) |
| go_router | Declarative navigation |
| Geolocator | Device location services |
| url_launcher | Open external apps (Google Maps) |

---

## 🚀 Getting Started

### Prerequisites

1. Flutter SDK 3.10.7 or higher
2. Mapbox access token (get one at [mapbox.com](https://mapbox.com))

### Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/VeloFactory/VeloMap.git
   cd VeloMap/mobile/client/velo_map_app
   ```

2. **Create environment file**
   ```bash
   cp .env.example .env
   ```

3. **Add your Mapbox key to `.env`**
   ```
   MAPBOX_KEY=your_mapbox_access_token_here
   ```

4. **Install dependencies**
   ```bash
   flutter pub get
   ```

5. **Run code generation** (for Freezed models)
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

6. **Run the app**
   ```bash
   flutter run
   ```

---

## 🏗️ Architecture Overview

VeloMap follows **Clean Architecture** principles, separating concerns into distinct layers:

```
┌─────────────────────────────────────────────────────────────┐
│                     PRESENTATION LAYER                       │
│  (UI Widgets, BLoC, MapController, Screens)                 │
├─────────────────────────────────────────────────────────────┤
│                       DOMAIN LAYER                           │
│  (Entities, Value Models, Repository Interfaces)            │
├─────────────────────────────────────────────────────────────┤
│                        DATA LAYER                            │
│  (DTOs, Datasources, Repository Implementations)            │
└─────────────────────────────────────────────────────────────┘
```

### Dependency Rule

Dependencies point **inward** — outer layers depend on inner layers, never the reverse:

```
Presentation → Domain ← Data
```

The **Domain layer** has no dependencies on other layers.

---

## 📁 Folder Structure

```
lib/
├── main.dart                         # App entry point
├── app/
│   ├── app.dart                      # Root widget with providers
│   └── router.dart                   # go_router navigation config
│
├── core/
│   ├── errors/
│   │   ├── bloc_observable.dart      # Global BLoC error logging
│   │   ├── data_exceptions.dart      # Data layer exception types
│   │   └── failure.dart              # Failure types for Either
│   ├── network/
│   │   └── api_client.dart           # HTTP client (future use)
│   ├── theme/
│   │   └── app_theme.dart            # Light / dark MaterialTheme
│   └── utils/
│       └── gpx_exporter.dart         # Export route to GPX file
│
└── features/
    ├── routes/                       # Main feature
    │   ├── routes.dart               # Entry screen (Routes widget)
    │   ├── data/
    │   │   ├── datasources/
    │   │   │   ├── routes_local_datasource.dart   # Reads GeoJSON from assets
    │   │   │   └── routes_remote_datasource.dart  # Future remote source
    │   │   ├── models/
    │   │   │   ├── route_dto.dart                 # GeoJSON → DTO
    │   │   │   ├── route_dto.freezed.dart          # Generated
    │   │   │   └── route_dto.g.dart               # Generated
    │   │   └── repositories/
    │   │       └── route_repository_impl.dart     # DTO → Entity
    │   ├── domain/
    │   │   ├── entities/
    │   │   │   ├── route_entity.dart              # Route business model
    │   │   │   └── route_stage_entity.dart        # Individual stage model
    │   │   └── models/
    │   │       ├── map_layer_config.dart          # POI layer toggle config
    │   │       └── route_stage_status.dart        # Stage status enum
    │   └── presentation/
    │       ├── bloc/
    │       │   ├── routes_bloc.dart
    │       │   ├── routes_event.dart
    │       │   └── routes_state.dart
    │       ├── services/
    │       │   └── map_controller.dart            # All Mapbox operations
    │       └── widgets/
    │           ├── map_layers_sheet.dart          # POI layer toggle sheet
    │           ├── poi_info_sheet.dart            # POI tap info popup
    │           ├── route_list_tile.dart           # Route list item
    │           ├── routes_bottom_sheet.dart       # Draggable route list
    │           └── routes_search_bar.dart         # City search bar
    │
    ├── poi/                          # Reserved for future dedicated POI feature
    │   └── presentation/
    │       ├── cubit/                # (empty placeholder)
    │       └── widgets/              # (empty placeholder)
    │
    └── navigation/                   # Reserved for future navigation feature
        └── navigation.dart
```

### Assets

```
assets/
├── icons/
│   └── launcher_icon.png
└── routes/
    └── geojson/                      # EuroVelo route data (EuroVelo 1–19)
```

---

## 🔄 State Management

VeloMap uses **flutter_bloc** with the BLoC pattern for the Routes feature.

### BLoC Pattern

```
┌──────────────┐     ┌──────────┐     ┌──────────┐
│    Event     │ ──▶ │   BLoC   │ ──▶ │  State   │
└──────────────┘     └──────────┘     └──────────┘
  (User action)    (Business logic)   (UI updates)
```

**Events** (`routes_event.dart`):
```dart
@freezed
sealed class RoutesEvent with _$RoutesEvent {
  const factory RoutesEvent.load() = Load;
  const factory RoutesEvent.selectRoute(RouteEntity route) = SelectRoute;
  const factory RoutesEvent.selectStage(RouteStageEntity stage) = SelectStage;
  const factory RoutesEvent.clearSelection() = ClearSelection;
  const factory RoutesEvent.clearSearch() = ClearSearch;
  const factory RoutesEvent.search(String query) = Search;
}
```

**State** (`routes_state.dart`):
```dart
@freezed
class RoutesState with _$RoutesState {
  const factory RoutesState({
    @Default([]) List<RouteEntity> routes,
    @Default(false) bool isLoading,
    String? error,
    RouteEntity? selectedRoute,
    RouteStageEntity? selectedStage,
    @Default('') String searchQuery,
  }) = _RoutesState;
}
```

### POI Layer State

POI layer visibility is **not** managed by a separate Cubit. It is a plain `MapLayerConfig` value object held directly in `_RoutesState` of the `Routes` screen widget. When the user toggles layers in `MapLayersSheet`, the callback updates `_layerConfig` via `setState` and calls `MapController.updatePoiLayers(config)` directly.

```dart
// domain/models/map_layer_config.dart
class MapLayerConfig {
  final bool showHotels;
  final bool showRestaurants;
  final bool showCamping;
}
```

This keeps the POI toggle logic simple and co-located with the map screen that owns it.

---

## 📊 Data Flow

### Loading Routes

```
App startup
  → RoutesBloc dispatches Load event
  → RoutesBloc._onLoad() calls RouteRepository.getRoutes()
  → RouteRepositoryImpl calls RouteLocalDatasource.fetchRoutes()
  → RouteLocalDatasource reads GeoJSON from assets/ → parses to RouteDto
  → Repository converts RouteDto → RouteEntity
  → Returns Either<Failure, List<RouteEntity>>
  → BLoC emits RoutesState(routes: [...])
  → BlocConsumer rebuilds UI → MapController draws routes on map
```

### Selecting a Route

```
User taps route polyline on map
  → MapController polyline tap listener fires
  → _onRouteTapped(routeId) dispatches SelectRoute event
  → BLoC emits state with selectedRoute set
  → BlocConsumer.listener → MapController.updateMapDisplay(singleRoute)
  → Map re-draws single route, camera fits to its bounds
  → Bottom sheet expands to mid size
```

### POI Layer Toggle

```
User taps layers FAB
  → MapLayersSheet.show() opens modal bottom sheet
  → User toggles hotel/restaurant/camping switches
  → onConfigChanged(newConfig) callback fires
  → _layerConfig updated via setState
  → MapController.updatePoiLayers(config) sets Mapbox layer visibility
```

### POI Tap Flow

```
User taps a visible POI dot on the map
  → MapWidget.onTapListener fires with ScreenCoordinate
  → MapController.handleMapTap(position)
  → mapboxMap.queryRenderedFeatures with POI layer IDs
  → Feature properties extracted (name, class, coordinates)
  → _poiTapCallback(PoiInfo) fires
  → PoiInfoSheet.show(context, poi) opens bottom sheet
  → User can open in Google Maps or copy name
```

### Error Handling with Either

```dart
Future<Either<Failure, List<RouteEntity>>> getRoutes() async {
  try {
    final dtos = await _datasource.fetchRoutes();
    return Right(dtos.map((e) => e.toEntity()).toList());
  } catch (e) {
    return Left(UnknownFailure('Error loading routes'));
  }
}
```

BLoC handles both cases:
```dart
result.fold(
  (failure) => emit(state.copyWith(error: failure.message)),
  (routes) => emit(state.copyWith(routes: routes)),
);
```

---

## 🧩 Feature Modules

### Routes Feature (`lib/features/routes/`)

The only active feature. Manages EuroVelo routes, map display, POI layers, and stage tracking.

#### Data Layer
- **`RouteLocalDatasource`** — Reads GeoJSON files from `assets/routes/geojson/`, parses them into `RouteDto`
- **`RouteDto`** — Handles both `FeatureCollection` (multi-stage) and single-`Feature` GeoJSON
- **`RouteRepositoryImpl`** — Converts DTOs to `RouteEntity` domain objects

#### Domain Layer
- **`RouteEntity`** — Route with computed properties (`centerPoint`, `boundingBox`, `coordinates`)
- **`RouteStageEntity`** — A named segment of a route with coordinates, distance, and status
- **`RouteStageStatus`** — Enum: `planned | inProgress | completed`, carries color and icon
- **`MapLayerConfig`** — Value object for POI layer visibility flags

#### Presentation Layer
- **`RoutesBloc`** — Manages loading, route/stage selection, and search filter
- **`MapController`** — All Mapbox map operations (see Key Components)
- **`Routes`** — Main screen: hosts `MapWidget` + `DraggableScrollableSheet`
- **`RoutesBottomSheet`** — Route list, stage list, and route detail inside a draggable sheet
- **`RouteListTile`** — Single route item with color swatch and distance
- **`RoutesSearchBar`** — City autocomplete search overlay
- **`MapLayersSheet`** — Modal sheet with POI category toggles
- **`PoiInfoSheet`** — Modal sheet shown when a POI is tapped on the map

### POI Feature (`lib/features/poi/`)

Currently an **empty placeholder**. The `cubit/` and `widgets/` directories are reserved for a future self-contained POI feature (e.g. custom user-added POIs, offline POI data). Current POI functionality lives inside the Routes feature.

### Navigation Feature (`lib/features/navigation/`)

**Stub only** — reserved for future turn-by-turn navigation.

---

## 🔑 Key Components

### MapController (`presentation/services/map_controller.dart`)

Owns all interactions with the Mapbox SDK. Designed to be created once per `Routes` screen lifecycle.

#### Race-condition protection

Each call to `updateMapDisplay` captures an incrementing `_drawOperationId`. After every `await`, the method checks whether its captured ID is still current; if not, it exits early. This prevents stale draw operations when the user rapidly switches routes.

#### Public API

```dart
// Setup (called in _onMapCreated)
void setMapboxMap(MapboxMap map)
void setPolylineManager(PolylineAnnotationManager manager)
void setPointManager(PointAnnotationManager manager)
void setRouteTapHandler(void Function(String routeId) onRouteTap)
void setPOITapHandler(void Function(PoiInfo) callback)
Future<void> configureMapSettings()

// Map display — unified entry point
Future<void> updateMapDisplay({
  required MapDisplayMode mode,   // allRoutes | singleRoute | singleStage | empty
  List<RouteEntity>? allRoutes,
  RouteEntity? selectedRoute,
  RouteStageEntity? selectedStage,
  bool fitCamera = true,
})

// Camera
Future<void> goToUserLocation()
Future<void> moveToCurrentLocation()   // no animation, used at startup
Future<void> resetBearing()
Future<void> fitCameraToBounds(List<double> bbox)
Future<void> fitCameraToRoutes(List<RouteEntity> routes)

// POI layers (Mapbox Streets v8 vector tiles)
Future<void> initPoiLayers()                          // call once after map created
Future<void> updatePoiLayers(MapLayerConfig config)   // show/hide by category
Future<void> handleMapTap(ScreenCoordinate position)  // query features at tap point
```

#### POI layer architecture

`initPoiLayers` adds six style layers to the Mapbox map at runtime using the `mapbox.mapbox-streets-v8` vector tile source:

| Layer ID | Type | Source layer | Class filter | Min zoom |
|---|---|---|---|---|
| `velo-poi-hotels` | circle | `poi_label` | `lodging` | 12 |
| `velo-poi-hotels-label` | symbol | `poi_label` | `lodging` | 14 |
| `velo-poi-restaurants` | circle | `poi_label` | `food_and_drink` | 12 |
| `velo-poi-restaurants-label` | symbol | `poi_label` | `food_and_drink` | 14 |
| `velo-poi-camping` | circle | `poi_label` | `campsite` | 12 |
| `velo-poi-camping-label` | symbol | `poi_label` | `campsite` | 14 |

All layers start hidden (`visibility: none`). The native Mapbox POI labels are hidden via the Standard style import config and the legacy `poi-label` layer.

#### PoiInfo / PoiCategory

```dart
enum PoiCategory { hotel, restaurant, camping, other }

class PoiInfo {
  final String name;
  final PoiCategory category;
  final double lat;
  final double lng;
}
```

### RouteDto (`data/models/route_dto.dart`)

Parses GeoJSON into route data:

```dart
factory RouteDto.fromGeoJson(Map<String, dynamic> geoJson) {
  final type = geoJson['type'];
  if (type == 'FeatureCollection') {
    return _fromFeatureCollection(geoJson);  // Multi-stage route
  }
  return _fromSingleFeature(geoJson);        // Simple single-stage route
}
```

Handles both `LineString` and `MultiLineString` geometries (including gaps for ferry crossings).

### App Configuration (`app/app.dart`)

```dart
class App extends StatelessWidget {
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<RouteRepository>(create: (_) => RouteRepositoryImpl()),
      ],
      child: Builder(builder: (context) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<RoutesBloc>(
              create: (context) =>
                  RoutesBloc(repository: context.read<RouteRepository>())
                    ..add(const RoutesEvent.load()),
            ),
          ],
          child: MaterialApp.router(
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: ThemeMode.system,
            routerConfig: router,
          ),
        );
      }),
    );
  }
}
```

Only `RoutesBloc` is registered globally. POI state lives locally in the `Routes` screen.

---

## ⚙️ Code Generation

VeloMap uses code generation for:

1. **Freezed** — Immutable classes, union types, `copyWith`
2. **json_serializable** — JSON serialization for DTOs

### Running Build Runner

```bash
# One-time build
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (auto-rebuild on changes)
flutter pub run build_runner watch --delete-conflicting-outputs
```

### Generated Files

- `*.freezed.dart` — Freezed implementations
- `*.g.dart` — JSON serialization helpers

---

## ➕ Adding New Features

### 1. Create Feature Folder

```
lib/features/new_feature/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   └── models/
└── presentation/
    ├── bloc/   (or cubit/)
    └── widgets/
```

### 2. Define Domain Entities

```dart
class MyEntity {
  final String id;
  final String name;
  const MyEntity({required this.id, required this.name});
}
```

### 3. Create Data Models (Freezed + json_serializable)

```dart
@freezed
sealed class MyDto with _$MyDto {
  const factory MyDto({required String id, required String name}) = _MyDto;
  factory MyDto.fromJson(Map<String, dynamic> json) => _$MyDtoFromJson(json);
  MyEntity toEntity() => MyEntity(id: id, name: name);
}
```

### 4. Implement Repository

```dart
abstract class MyRepository {
  Future<Either<Failure, List<MyEntity>>> getAll();
}

class MyRepositoryImpl implements MyRepository {
  @override
  Future<Either<Failure, List<MyEntity>>> getAll() async {
    try {
      final dtos = await _datasource.fetch();
      return Right(dtos.map((e) => e.toEntity()).toList());
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
```

### 5. Create BLoC

```dart
class MyBloc extends Bloc<MyEvent, MyState> {
  MyBloc({required MyRepository repository})
      : _repository = repository,
        super(const MyState()) {
    on<LoadMyData>(_onLoad);
  }
}
```

### 6. Register in App

```dart
// app/app.dart
BlocProvider<MyBloc>(
  create: (context) => MyBloc(repository: context.read()),
),
```

### 7. Add Route (if needed)

```dart
// app/router.dart
GoRoute(path: '/my-feature', builder: (_, __) => const MyScreen()),
```

---

## 📚 Resources

- [Flutter BLoC Documentation](https://bloclibrary.dev/)
- [Freezed Package](https://pub.dev/packages/freezed)
- [Mapbox Maps Flutter SDK](https://docs.mapbox.com/flutter/)
- [go_router Documentation](https://pub.dev/packages/go_router)

---

## 🤝 Contributing

1. Follow the existing Clean Architecture layer separation
2. Run `build_runner` after modifying Freezed classes
3. Keep features self-contained in their feature folders
4. Use `Either<Failure, T>` for error handling in repositories
5. Add all Mapbox map operations to `MapController`, never directly in widgets

Happy coding! 🚴‍♂️