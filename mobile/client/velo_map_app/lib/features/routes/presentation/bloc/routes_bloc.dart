import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/routes_repository.dart';
import 'routes_event.dart';
import 'routes_state.dart';

class RoutesBloc extends Bloc<RoutesEvent, RoutesState> {
  final RoutesRepository repository;

  RoutesBloc({required this.repository}) : super(const RoutesState.loading()) {
    on((event, emit) async {
      final result = await repository.getRoutes();

      result.fold(
        (failure) => emit(RoutesState.error(failure.message)),
        (routes) => emit(RoutesState.loaded(routes)),
      );
    });
  }
}
