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
    @Default([]) List<RouteEntity> plannedRoutes,
  }) = _RoutesState;

  /// Returns filtered routes based on search query matching city names,
  /// with planned routes at the top, then selected route, then the rest
  List<RouteEntity> get filteredRoutes {
    List<RouteEntity> filtered;

    if (searchQuery.isEmpty) {
      filtered = routes;
    } else {
      final query = searchQuery.toLowerCase();
      filtered = routes.where((route) {
        // Check if any city contains the search query
        return route.cities.any((city) => city.toLowerCase().contains(query));
      }).toList();
    }

    // Put selected route at top
    if (selectedRoute != null) {
      final selectedIndex = filtered.indexWhere(
        (r) => r.id == selectedRoute!.id,
      );
      if (selectedIndex > 0) {
        // Create a new list with selected route at top
        final result = <RouteEntity>[selectedRoute!];
        for (int i = 0; i < filtered.length; i++) {
          if (i != selectedIndex) {
            result.add(filtered[i]);
          }
        }
        filtered = result;
      }
    }

    // When planner mode is active, show ONLY the planned routes
    if (plannedRoutes.isNotEmpty) {
      return plannedRoutes;
    }

    return filtered;
  }

  /// Whether search is active
  bool get isSearchActive => searchQuery.isNotEmpty;

  /// Whether there are active planned routes
  bool get hasPlannedRoutes => plannedRoutes.isNotEmpty;
}
