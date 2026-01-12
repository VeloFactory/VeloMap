import 'package:velo_map_app/features/routes/domain/entities/route_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'routes_state.freezed.dart';

@freezed
class RoutesState with _$RoutesState {
  const factory RoutesState.loading() = _Loading;
  const factory RoutesState.loaded(List<RouteEntity> routes) = _Loaded;
  const factory RoutesState.error(String message) = _Error;
}
