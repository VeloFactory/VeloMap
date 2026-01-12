import 'package:freezed_annotation/freezed_annotation.dart';

part 'routes_event.freezed.dart';

@freezed
class RoutesEvent with _$RoutesEvent {
  const factory RoutesEvent.requested() = _Requested;
}
