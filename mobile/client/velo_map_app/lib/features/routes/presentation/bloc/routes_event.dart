import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:velo_map_app/features/routes/domain/entities/route_entity.dart';
import 'package:velo_map_app/features/routes/domain/entities/route_stage_entity.dart';

part 'routes_event.freezed.dart';

// Events
@freezed
sealed class RoutesEvent with _$RoutesEvent {
  const factory RoutesEvent.load() = Load;
  const factory RoutesEvent.selectRoute(RouteEntity route) = SelectRoute;
  const factory RoutesEvent.clearSelection() = ClearSelection;
  const factory RoutesEvent.selectStage(RouteStageEntity stage) = SelectStage;
  const factory RoutesEvent.clearStageSelection() = ClearStageSelection;
  const factory RoutesEvent.search(String query) = Search;
  const factory RoutesEvent.clearSearch() = ClearSearch;
  const factory RoutesEvent.setPlannedRoutes(List<RouteEntity> routes) =
      SetPlannedRoutes;
  const factory RoutesEvent.clearPlannedRoutes() = ClearPlannedRoutes;
}
