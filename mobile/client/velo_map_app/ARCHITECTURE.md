# VeloMap Architecture Guide

Welcome to VeloMap! This guide will help you understand the project architecture, data flow, and codebase organization.

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

- 🗺️ Interactive map with cycling routes
- 🔍 Search routes by city
- 📍 User location tracking
- 🏨 POI (Points of Interest) layer toggles (hotels, campings, restaurants)
- 📊 Route details with stages, distance, and elevation
- 🧭 Turn-by-turn navigation (coming soon)

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
│  (UI Widgets, BLoC/Cubit, MapController, Screens)           │
├─────────────────────────────────────────────────────────────┤
│                       DOMAIN LAYER                           │
│  (Entities, Business Logic, Repository Interfaces)          │
├─────────────────────────────────────────────────────────────┤
│                        DATA LAYER                            │
│  (DTOs, Datasources, Repository Implementations)            │
└─────────────────────────────────────────────────────────────┘
```

### Why Clean Architecture?

1. **Separation of Concerns** - Each layer has a single responsibility
2. **Testability** - Easy to mock dependencies and write unit tests
3. **Maintainability** - Changes in one layer don't affect others
4. **Scalability** - Easy to add new features without touching existing code

### Dependency Rule

Dependencies point **inward** - outer layers depend on inner layers, never the reverse:

```
Presentation → Domain ← Data
```

The **Domain layer** is the core and has no dependencies on other layers.

---

## 📁 Folder Structure

```
lib/
├── main.dart                    # App entry point
├── app/                         # Application configuration
│   ├── app.dart                 # Root widget with providers
│   └── router.dart              # Navigation routes (go_router)
│
├── core/                        # Shared utilities
│   ├── errors/                  # Error handling
│   │   ├── bloc_observable.dart # BLoC error logging
│   │   ├── data_exceptions.dart # Data layer exceptions
│   │   └── failure.dart         # Failure types for Either
│   ├── network/                 # API client (for future use)
│   │   └── api_client.dart
│   └── theme/                   # App theming
│       └── app_theme.dart
│
└── features/                    # Feature modules
    ├── routes/                  # Main routes feature
    │   ├── routes.dart          # Barrel file (exports)
    │   ├── data/                # Data layer
    │   │   ├── datasources/     # Data sources
    │   │   ├── models/          # DTOs (Data Transfer Objects)
    │   │   └── repositories/    # Repository implementations
    │   ├── domain/              # Domain layer
    │   │   ├── entities/        # Business entities
    │   │   └── services/        # Domain services
    │   └── presentation/        # Presentation layer
    │       ├── bloc/            # BLoC (events, states)
    │       ├── services/        # UI services (MapController)
    │       └── widgets/         # UI components
    │
    ├── poi/                     # Points of Interest feature
    │   ├── poi.dart             # Barrel file
    │   └── presentation/
    │       ├── cubit/           # Cubit for simple state
    │       └── widgets/
    │
    └── navigation/              # Navigation feature (planned)
        └── navigation.dart

assets/
├── icons/                       # App icons
└── routes/
    └── geojson/                 # Route data files (EuroVelo 1-19)
```

### Barrel Files

Each feature has a `feature.dart` barrel file that exports public APIs:

```dart
// lib/features/poi/poi.dart
export 'presentation/cubit/poi_layers_cubit.dart';
export 'presentation/cubit/poi_layers_state.dart';
export 'presentation/widgets/poi_layers_button.dart';
```

This allows clean imports: `import 'package:velo_map_app/features/poi/poi.dart';`

---

## 🔄 State Management

VeloMap uses **flutter_bloc** with two patterns:

### 1. BLoC Pattern (for complex features)

Used for the Routes feature with multiple events and complex state transitions.

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
  const factory RoutesEvent.clearSelection() = ClearSelection;
  const factory RoutesEvent.search(String query) = Search;
  // ...
}
```

**State** (`routes_state.dart`):
```dart
@freezed
sealed class RoutesState with _$RoutesState {
  const factory RoutesState({
    @Default([]) List<RouteEntity> routes,
    @Default(false) bool isLoading,
    String? error,
    RouteEntity? selectedRoute,
    // ...
  }) = _RoutesState;
}
```

### 2. Cubit Pattern (for simple features)

Used for POI layers with simple toggle operations.

```dart
class PoiLayersCubit extends HydratedCubit<PoiLayersState> {
  void toggleHotels() {
    emit(state.copyWith(showHotels: !state.showHotels));
  }
}
```

### HydratedBloc for Persistence

POI settings persist across app restarts using `hydrated_bloc`:

```dart
class PoiLayersCubit extends HydratedCubit<PoiLayersState> {
  @override
  PoiLayersState? fromJson(Map<String, dynamic> json) {
    return PoiLayersState(showHotels: json['showHotels'] ?? false);
  }

  @override
  Map<String, dynamic>? toJson(PoiLayersState state) {
    return {'showHotels': state.showHotels};
  }
}
```

---

## 📊 Data Flow

### Loading Routes

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           APP STARTUP                                    │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│  1. RoutesBloc created → dispatches Load event                          │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│  2. RoutesBloc._onLoad() calls repository.getRoutes()                   │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│  3. RouteRepositoryImpl calls datasource.fetchRoutes()                  │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│  4. RouteLocalDatasource reads GeoJSON files from assets                │
│     - Parses JSON → RouteDto objects                                    │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│  5. Repository converts DTOs → RouteEntity (domain objects)             │
│     - Returns Either<Failure, List<RouteEntity>>                        │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│  6. BLoC emits new RoutesState with loaded routes                       │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│  7. BlocConsumer rebuilds UI → MapController draws routes on map        │
└─────────────────────────────────────────────────────────────────────────┘
```

### Selecting a Route

```
User taps route → SelectRoute event → BLoC emits state with selectedRoute
                                            │
                                            ▼
                    BlocConsumer.listener → MapController.drawRoute()
                                            │
                                            ▼
                              Map zooms to route, bottom sheet expands
```

### Error Handling with Either

The repository returns `Either<Failure, T>` for explicit error handling:

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

The main feature displaying cycling routes on the map.

#### Data Layer
- **`RouteLocalDatasource`** - Reads GeoJSON files from assets
- **`RouteDto`** - Data Transfer Object with JSON parsing
- **`RouteRepositoryImpl`** - Converts DTOs to entities

#### Domain Layer
- **`RouteEntity`** - Business model with computed properties (centerPoint, boundingBox)
- **`RouteStageEntity`** - Individual stage of a multi-stage route
- **`RouteColorResolver`** - Assigns colors to routes

#### Presentation Layer
- **`RoutesBloc`** - Manages routes state (loading, selection, search)
- **`MapController`** - Manages Mapbox map operations
- **`RoutesBottomSheet`** - UI for route list and details
- **`RoutesSearchBar`** - Search by city functionality

### POI Feature (`lib/features/poi/`)

Manages Points of Interest visibility on the map.

- **`PoiLayersCubit`** - Simple state for toggling POI layers
- **`PoiLayersButton`** - UI button with dropdown for layer selection
- Uses `HydratedCubit` for persistent state

### Navigation Feature (`lib/features/navigation/`)

**Coming soon** - Will provide turn-by-turn navigation.

---

## 🔑 Key Components

### MapController (`presentation/services/map_controller.dart`)

Manages all Mapbox map operations:

```dart
class MapController {
  MapboxMap? _mapboxMap;
  PolylineAnnotationManager? _polylineManager;
  
  // Camera operations
  Future<void> fitCameraToRoutes(List<RouteEntity> routes);
  Future<void> goToUserLocation();
  
  // Route drawing
  Future<void> drawRoute(RouteEntity route, int lineColor);
  Future<void> drawRoutes(List<RouteEntity> routes);
  Future<void> clearRoute();
  
  // POI layers
  Future<void> updatePoiLayers(PoiLayersState state);
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
  return _fromSingleFeature(geoJson);  // Simple route
}
```

Handles both `LineString` and `MultiLineString` geometries, including gaps (ferry crossings).

### App Configuration (`app/app.dart`)

Sets up providers and BLoC:

```dart
class App extends StatelessWidget {
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<RouteRepository>(create: (_) => RouteRepositoryImpl()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<RoutesBloc>(
            create: (context) => RoutesBloc(repository: context.read())
              ..add(const RoutesEvent.load()),
          ),
          BlocProvider<PoiLayersCubit>(
            create: (_) => PoiLayersCubit(),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
  }
}
```

---

## ⚙️ Code Generation

VeloMap uses code generation for:

1. **Freezed** - Immutable classes, union types, copyWith
2. **json_serializable** - JSON serialization

### Running Build Runner

```bash
# One-time build
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (auto-rebuild on changes)
flutter pub run build_runner watch --delete-conflicting-outputs
```

### Generated Files

- `*.freezed.dart` - Freezed implementations
- `*.g.dart` - JSON serialization

### Example Freezed Class

```dart
// routes_state.dart
@freezed
sealed class RoutesState with _$RoutesState {
  const factory RoutesState({
    @Default([]) List<RouteEntity> routes,
    @Default(false) bool isLoading,
  }) = _RoutesState;
}
```

Generates:
- `copyWith()` method
- `==` operator and `hashCode`
- `toString()`

---

## ➕ Adding New Features

### 1. Create Feature Folder

```
lib/features/new_feature/
├── new_feature.dart           # Barrel file
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/
│   └── entities/
└── presentation/
    ├── bloc/  (or cubit/)
    └── widgets/
```

### 2. Define Domain Entities

```dart
// domain/entities/my_entity.dart
class MyEntity {
  final String id;
  final String name;
  
  const MyEntity({required this.id, required this.name});
}
```

### 3. Create Data Models

```dart
// data/models/my_dto.dart
@freezed
sealed class MyDto with _$MyDto {
  const factory MyDto({
    required String id,
    required String name,
  }) = _MyDto;

  factory MyDto.fromJson(Map<String, dynamic> json) => _$MyDtoFromJson(json);
  
  MyEntity toEntity() => MyEntity(id: id, name: name);
}
```

### 4. Implement Repository

```dart
// data/repositories/my_repository_impl.dart
abstract class MyRepository {
  Future<Either<Failure, List<MyEntity>>> getAll();
}

class MyRepositoryImpl implements MyRepository {
  final MyDatasource _datasource;
  
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

### 5. Create BLoC/Cubit

```dart
// presentation/bloc/my_bloc.dart
class MyBloc extends Bloc<MyEvent, MyState> {
  final MyRepository _repository;
  
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
MultiBlocProvider(
  providers: [
    // ... existing providers
    BlocProvider<MyBloc>(
      create: (context) => MyBloc(repository: context.read()),
    ),
  ],
)
```

### 7. Add Route (if needed)

```dart
// app/router.dart
final router = GoRouter(
  routes: [
    GoRoute(path: '/my-feature', builder: (_, __) => const MyScreen()),
  ],
);
```

---

## 📚 Resources

- [Flutter BLoC Documentation](https://bloclibrary.dev/)
- [Freezed Package](https://pub.dev/packages/freezed)
- [Clean Architecture in Flutter](https://resocoder.com/clean-architecture-tdd/)
- [Mapbox Maps Flutter SDK](https://docs.mapbox.com/flutter/)
- [go_router Documentation](https://pub.dev/packages/go_router)

---

## 🤝 Contributing

1. Follow the existing architecture patterns
2. Run code generation after modifying Freezed classes
3. Keep features self-contained in their feature folders
4. Use `Either<Failure, T>` for error handling in repositories
5. Write barrel files for clean imports

Happy coding! 🚴‍♂️
