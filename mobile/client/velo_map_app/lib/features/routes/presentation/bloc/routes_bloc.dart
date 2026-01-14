import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:velo_map_app/features/routes/data/repositories/route_repository_impl.dart';
import 'package:velo_map_app/features/routes/presentation/bloc/routes_event.dart';
import 'package:velo_map_app/features/routes/presentation/bloc/routes_state.dart';

// Bloc
class RoutesBloc extends Bloc<RoutesEvent, RoutesState> {
  final RouteRepository _repository;

  RoutesBloc({required RouteRepository repository})
    : _repository = repository,
      super(const RoutesState()) {
    on<Load>(_onLoad);
    on<SelectRoute>(_onSelectRoute);
    on<ClearSelection>(_onClearSelection);
    on<SelectStage>(_onSelectStage);
    on<ClearStageSelection>(_onClearStageSelection);
  }

  Future<void> _onLoad(Load event, Emitter<RoutesState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));

    final result = await _repository.getRoutes();

    result.fold(
      (failure) {
        final message = failure.toString();
        emit(state.copyWith(isLoading: false, error: message));
      },
      (routes) {
        emit(state.copyWith(routes: routes, isLoading: false));
      },
    );
  }

  void _onSelectRoute(SelectRoute event, Emitter<RoutesState> emit) {
    emit(state.copyWith(selectedRoute: event.route, selectedStage: null));
  }

  void _onClearSelection(ClearSelection event, Emitter<RoutesState> emit) {
    emit(state.copyWith(selectedRoute: null, selectedStage: null));
  }

  void _onSelectStage(SelectStage event, Emitter<RoutesState> emit) {
    emit(state.copyWith(selectedStage: event.stage));
  }

  void _onClearStageSelection(
    ClearStageSelection event,
    Emitter<RoutesState> emit,
  ) {
    emit(state.copyWith(selectedStage: null));
  }
}
