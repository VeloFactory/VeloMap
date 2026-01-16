// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'routes_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RoutesState {

 List<RouteEntity> get routes; bool get isLoading; String? get error; RouteEntity? get selectedRoute; RouteStageEntity? get selectedStage; String get searchQuery;
/// Create a copy of RoutesState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoutesStateCopyWith<RoutesState> get copyWith => _$RoutesStateCopyWithImpl<RoutesState>(this as RoutesState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoutesState&&const DeepCollectionEquality().equals(other.routes, routes)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.error, error) || other.error == error)&&(identical(other.selectedRoute, selectedRoute) || other.selectedRoute == selectedRoute)&&(identical(other.selectedStage, selectedStage) || other.selectedStage == selectedStage)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(routes),isLoading,error,selectedRoute,selectedStage,searchQuery);

@override
String toString() {
  return 'RoutesState(routes: $routes, isLoading: $isLoading, error: $error, selectedRoute: $selectedRoute, selectedStage: $selectedStage, searchQuery: $searchQuery)';
}


}

/// @nodoc
abstract mixin class $RoutesStateCopyWith<$Res>  {
  factory $RoutesStateCopyWith(RoutesState value, $Res Function(RoutesState) _then) = _$RoutesStateCopyWithImpl;
@useResult
$Res call({
 List<RouteEntity> routes, bool isLoading, String? error, RouteEntity? selectedRoute, RouteStageEntity? selectedStage, String searchQuery
});




}
/// @nodoc
class _$RoutesStateCopyWithImpl<$Res>
    implements $RoutesStateCopyWith<$Res> {
  _$RoutesStateCopyWithImpl(this._self, this._then);

  final RoutesState _self;
  final $Res Function(RoutesState) _then;

/// Create a copy of RoutesState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? routes = null,Object? isLoading = null,Object? error = freezed,Object? selectedRoute = freezed,Object? selectedStage = freezed,Object? searchQuery = null,}) {
  return _then(_self.copyWith(
routes: null == routes ? _self.routes : routes // ignore: cast_nullable_to_non_nullable
as List<RouteEntity>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,selectedRoute: freezed == selectedRoute ? _self.selectedRoute : selectedRoute // ignore: cast_nullable_to_non_nullable
as RouteEntity?,selectedStage: freezed == selectedStage ? _self.selectedStage : selectedStage // ignore: cast_nullable_to_non_nullable
as RouteStageEntity?,searchQuery: null == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RoutesState].
extension RoutesStatePatterns on RoutesState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RoutesState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RoutesState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RoutesState value)  $default,){
final _that = this;
switch (_that) {
case _RoutesState():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RoutesState value)?  $default,){
final _that = this;
switch (_that) {
case _RoutesState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<RouteEntity> routes,  bool isLoading,  String? error,  RouteEntity? selectedRoute,  RouteStageEntity? selectedStage,  String searchQuery)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RoutesState() when $default != null:
return $default(_that.routes,_that.isLoading,_that.error,_that.selectedRoute,_that.selectedStage,_that.searchQuery);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<RouteEntity> routes,  bool isLoading,  String? error,  RouteEntity? selectedRoute,  RouteStageEntity? selectedStage,  String searchQuery)  $default,) {final _that = this;
switch (_that) {
case _RoutesState():
return $default(_that.routes,_that.isLoading,_that.error,_that.selectedRoute,_that.selectedStage,_that.searchQuery);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<RouteEntity> routes,  bool isLoading,  String? error,  RouteEntity? selectedRoute,  RouteStageEntity? selectedStage,  String searchQuery)?  $default,) {final _that = this;
switch (_that) {
case _RoutesState() when $default != null:
return $default(_that.routes,_that.isLoading,_that.error,_that.selectedRoute,_that.selectedStage,_that.searchQuery);case _:
  return null;

}
}

}

/// @nodoc


class _RoutesState extends RoutesState {
  const _RoutesState({final  List<RouteEntity> routes = const [], this.isLoading = false, this.error, this.selectedRoute, this.selectedStage, this.searchQuery = ''}): _routes = routes,super._();
  

 final  List<RouteEntity> _routes;
@override@JsonKey() List<RouteEntity> get routes {
  if (_routes is EqualUnmodifiableListView) return _routes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_routes);
}

@override@JsonKey() final  bool isLoading;
@override final  String? error;
@override final  RouteEntity? selectedRoute;
@override final  RouteStageEntity? selectedStage;
@override@JsonKey() final  String searchQuery;

/// Create a copy of RoutesState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RoutesStateCopyWith<_RoutesState> get copyWith => __$RoutesStateCopyWithImpl<_RoutesState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RoutesState&&const DeepCollectionEquality().equals(other._routes, _routes)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.error, error) || other.error == error)&&(identical(other.selectedRoute, selectedRoute) || other.selectedRoute == selectedRoute)&&(identical(other.selectedStage, selectedStage) || other.selectedStage == selectedStage)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_routes),isLoading,error,selectedRoute,selectedStage,searchQuery);

@override
String toString() {
  return 'RoutesState(routes: $routes, isLoading: $isLoading, error: $error, selectedRoute: $selectedRoute, selectedStage: $selectedStage, searchQuery: $searchQuery)';
}


}

/// @nodoc
abstract mixin class _$RoutesStateCopyWith<$Res> implements $RoutesStateCopyWith<$Res> {
  factory _$RoutesStateCopyWith(_RoutesState value, $Res Function(_RoutesState) _then) = __$RoutesStateCopyWithImpl;
@override @useResult
$Res call({
 List<RouteEntity> routes, bool isLoading, String? error, RouteEntity? selectedRoute, RouteStageEntity? selectedStage, String searchQuery
});




}
/// @nodoc
class __$RoutesStateCopyWithImpl<$Res>
    implements _$RoutesStateCopyWith<$Res> {
  __$RoutesStateCopyWithImpl(this._self, this._then);

  final _RoutesState _self;
  final $Res Function(_RoutesState) _then;

/// Create a copy of RoutesState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? routes = null,Object? isLoading = null,Object? error = freezed,Object? selectedRoute = freezed,Object? selectedStage = freezed,Object? searchQuery = null,}) {
  return _then(_RoutesState(
routes: null == routes ? _self._routes : routes // ignore: cast_nullable_to_non_nullable
as List<RouteEntity>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,selectedRoute: freezed == selectedRoute ? _self.selectedRoute : selectedRoute // ignore: cast_nullable_to_non_nullable
as RouteEntity?,selectedStage: freezed == selectedStage ? _self.selectedStage : selectedStage // ignore: cast_nullable_to_non_nullable
as RouteStageEntity?,searchQuery: null == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
