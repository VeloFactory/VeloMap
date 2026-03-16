import 'package:velo_map_app/features/route_planner/domain/entities/route_plan_entity.dart';
import 'package:velo_map_app/features/routes/domain/entities/route_entity.dart';

enum RoutePlannerStatus { idle, searching, found, notFound, error }

class RoutePlannerState {
  final RoutePlannerStatus status;
  final String fromCity;
  final String toCity;
  final List<RoutePlanVariant> variants;
  final List<RouteEntity> plannedRoutes;
  final String? errorMessage;

  const RoutePlannerState({
    this.status = RoutePlannerStatus.idle,
    this.fromCity = '',
    this.toCity = '',
    this.variants = const [],
    this.plannedRoutes = const [],
    this.errorMessage,
  });

  RoutePlannerState copyWith({
    RoutePlannerStatus? status,
    String? fromCity,
    String? toCity,
    List<RoutePlanVariant>? variants,
    List<RouteEntity>? plannedRoutes,
    String? errorMessage,
  }) {
    return RoutePlannerState(
      status: status ?? this.status,
      fromCity: fromCity ?? this.fromCity,
      toCity: toCity ?? this.toCity,
      variants: variants ?? this.variants,
      plannedRoutes: plannedRoutes ?? this.plannedRoutes,
      errorMessage: errorMessage,
    );
  }

  bool get hasResults => plannedRoutes.isNotEmpty;
}