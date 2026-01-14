// State
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:velo_map_app/features/routes/domain/entities/route_entity.dart';
import 'package:velo_map_app/features/routes/domain/entities/route_stage_entity.dart';

part 'routes_state.freezed.dart';

@freezed
sealed class RoutesState with _$RoutesState {
  const factory RoutesState({
    @Default([]) List<RouteEntity> routes,
    @Default(false) bool isLoading,
    String? error,
    RouteEntity? selectedRoute,
    RouteStageEntity? selectedStage,
  }) = _RoutesState;
}
