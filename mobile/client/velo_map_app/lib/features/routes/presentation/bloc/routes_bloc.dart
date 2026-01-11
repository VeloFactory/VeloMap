import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:velo_map_app/features/routes/domain/models/route_model.dart';
import 'package:velo_map_app/features/routes/domain/repositories/route_repository.dart';

part 'routes_bloc.freezed.dart';

// Events
@freezed
sealed class RoutesEvent with _$RoutesEvent {
  const factory RoutesEvent.load() = _Load;
  const factory RoutesEvent.selectRoute(RouteModel route) = _SelectRoute;
  const factory RoutesEvent.clearSelection() = _ClearSelection;
}

// State
@freezed
sealed class RoutesState with _$RoutesState {
  const factory RoutesState({
    @Default([]) List<RouteModel> routes,
    @Default(false) bool isLoading,
    String? error,
    RouteModel? selectedRoute,
  }) = _RoutesState;
}

// Bloc
class RoutesBloc extends Bloc<RoutesEvent, RoutesState> {
  final RouteRepository _repository;

  RoutesBloc({required RouteRepository repository})
      : _repository = repository,
        super(const RoutesState()) {
    on<_Load>(_onLoad);
    on<_SelectRoute>(_onSelectRoute);
    on<_ClearSelection>(_onClearSelection);
  }

  Future<void> _onLoad(_Load event, Emitter<RoutesState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final routes = await _repository.getRoutes();
      emit(state.copyWith(
        routes: routes,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to load routes: $e',
      ));
    }
  }

  void _onSelectRoute(_SelectRoute event, Emitter<RoutesState> emit) {
    emit(state.copyWith(selectedRoute: event.route));
  }

  void _onClearSelection(_ClearSelection event, Emitter<RoutesState> emit) {
    emit(state.copyWith(selectedRoute: null));
  }
}
