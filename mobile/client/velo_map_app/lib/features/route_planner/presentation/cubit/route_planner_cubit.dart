import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:velo_map_app/features/route_planner/domain/services/route_planner_service.dart';
import 'package:velo_map_app/features/route_planner/presentation/cubit/route_planner_state.dart';
import 'package:velo_map_app/features/routes/domain/entities/route_entity.dart';

class RoutePlannerCubit extends Cubit<RoutePlannerState> {
  final RoutePlannerService _service;

  RoutePlannerCubit({required RoutePlannerService service})
      : _service = service,
        super(const RoutePlannerState());

  RoutePlannerService get service => _service;

  /// Initialize the planner graph with loaded routes.
  /// Call this once routes are available from the RoutesBloc.
  void initializeWithRoutes(List<RouteEntity> routes) {
    _service.initialize(routes);
  }

  /// Get all city names for autocomplete
  List<String> getCitySuggestions(String query) {
    if (!_service.isInitialized || query.trim().isEmpty) return [];

    final normalizedQuery = query.trim().toLowerCase();
    return _service.allCities
        .where((city) => city.toLowerCase().contains(normalizedQuery))
        .take(8)
        .toList()
      ..sort((a, b) {
        final aStarts = a.toLowerCase().startsWith(normalizedQuery);
        final bStarts = b.toLowerCase().startsWith(normalizedQuery);
        if (aStarts && !bStarts) return -1;
        if (!aStarts && bStarts) return 1;
        return a.compareTo(b);
      });
  }

  void setFromCity(String city) {
    emit(state.copyWith(fromCity: city));
  }

  void setToCity(String city) {
    emit(state.copyWith(toCity: city));
  }

  /// Search for a route plan between fromCity and toCity
  void findRoute() {
    final from = state.fromCity.trim();
    final to = state.toCity.trim();

    if (from.isEmpty || to.isEmpty) return;

    emit(state.copyWith(status: RoutePlannerStatus.searching));

    try {
      final variants = _service.findRoute(from, to);

      if (variants.isEmpty) {
        emit(state.copyWith(
          status: RoutePlannerStatus.notFound,
          variants: [],
          plannedRoutes: [],
        ));
        return;
      }

      // Convert variants to RouteEntity list for display in the route list
      final plannedRoutes = <RouteEntity>[];
      for (int i = 0; i < variants.length; i++) {
        plannedRoutes.add(variants[i].toRouteEntity(variantIndex: i));
      }

      emit(state.copyWith(
        status: RoutePlannerStatus.found,
        variants: variants,
        plannedRoutes: plannedRoutes,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: RoutePlannerStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Clear planned routes and reset state
  void clearPlan() {
    emit(const RoutePlannerState());
  }
}