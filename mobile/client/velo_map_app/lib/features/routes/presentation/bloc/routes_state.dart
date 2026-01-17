// State
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:velo_map_app/features/routes/domain/entities/route_entity.dart';
import 'package:velo_map_app/features/routes/domain/entities/route_stage_entity.dart';

part 'routes_state.freezed.dart';

@freezed
sealed class RoutesState with _$RoutesState {
  const RoutesState._();

  const factory RoutesState({
    @Default([]) List<RouteEntity> routes,
    @Default(false) bool isLoading,
    String? error,
    RouteEntity? selectedRoute,
    RouteStageEntity? selectedStage,
    @Default('') String searchQuery,
  }) = _RoutesState;

  /// Returns filtered routes based on search query matching city names
  List<RouteEntity> get filteredRoutes {
    if (searchQuery.isEmpty) return routes;

    final query = searchQuery.toLowerCase();
    return routes.where((route) {
      // Check if any city contains the search query
      return route.cities.any((city) => city.toLowerCase().contains(query));
    }).toList();
  }

  /// Whether search is active
  bool get isSearchActive => searchQuery.isNotEmpty;
}
