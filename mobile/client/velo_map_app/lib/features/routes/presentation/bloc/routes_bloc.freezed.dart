// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'routes_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RoutesEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoutesEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'RoutesEvent()';
}


}

/// @nodoc
class $RoutesEventCopyWith<$Res>  {
$RoutesEventCopyWith(RoutesEvent _, $Res Function(RoutesEvent) __);
}


/// Adds pattern-matching-related methods to [RoutesEvent].
extension RoutesEventPatterns on RoutesEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Load value)?  load,TResult Function( _SelectRoute value)?  selectRoute,TResult Function( _ClearSelection value)?  clearSelection,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Load() when load != null:
return load(_that);case _SelectRoute() when selectRoute != null:
return selectRoute(_that);case _ClearSelection() when clearSelection != null:
return clearSelection(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Load value)  load,required TResult Function( _SelectRoute value)  selectRoute,required TResult Function( _ClearSelection value)  clearSelection,}){
final _that = this;
switch (_that) {
case _Load():
return load(_that);case _SelectRoute():
return selectRoute(_that);case _ClearSelection():
return clearSelection(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Load value)?  load,TResult? Function( _SelectRoute value)?  selectRoute,TResult? Function( _ClearSelection value)?  clearSelection,}){
final _that = this;
switch (_that) {
case _Load() when load != null:
return load(_that);case _SelectRoute() when selectRoute != null:
return selectRoute(_that);case _ClearSelection() when clearSelection != null:
return clearSelection(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  load,TResult Function( RouteModel route)?  selectRoute,TResult Function()?  clearSelection,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Load() when load != null:
return load();case _SelectRoute() when selectRoute != null:
return selectRoute(_that.route);case _ClearSelection() when clearSelection != null:
return clearSelection();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  load,required TResult Function( RouteModel route)  selectRoute,required TResult Function()  clearSelection,}) {final _that = this;
switch (_that) {
case _Load():
return load();case _SelectRoute():
return selectRoute(_that.route);case _ClearSelection():
return clearSelection();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  load,TResult? Function( RouteModel route)?  selectRoute,TResult? Function()?  clearSelection,}) {final _that = this;
switch (_that) {
case _Load() when load != null:
return load();case _SelectRoute() when selectRoute != null:
return selectRoute(_that.route);case _ClearSelection() when clearSelection != null:
return clearSelection();case _:
  return null;

}
}

}

/// @nodoc


class _Load implements RoutesEvent {
  const _Load();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Load);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'RoutesEvent.load()';
}


}




/// @nodoc


class _SelectRoute implements RoutesEvent {
  const _SelectRoute(this.route);
  

 final  RouteModel route;

/// Create a copy of RoutesEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SelectRouteCopyWith<_SelectRoute> get copyWith => __$SelectRouteCopyWithImpl<_SelectRoute>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SelectRoute&&(identical(other.route, route) || other.route == route));
}


@override
int get hashCode => Object.hash(runtimeType,route);

@override
String toString() {
  return 'RoutesEvent.selectRoute(route: $route)';
}


}

/// @nodoc
abstract mixin class _$SelectRouteCopyWith<$Res> implements $RoutesEventCopyWith<$Res> {
  factory _$SelectRouteCopyWith(_SelectRoute value, $Res Function(_SelectRoute) _then) = __$SelectRouteCopyWithImpl;
@useResult
$Res call({
 RouteModel route
});


$RouteModelCopyWith<$Res> get route;

}
/// @nodoc
class __$SelectRouteCopyWithImpl<$Res>
    implements _$SelectRouteCopyWith<$Res> {
  __$SelectRouteCopyWithImpl(this._self, this._then);

  final _SelectRoute _self;
  final $Res Function(_SelectRoute) _then;

/// Create a copy of RoutesEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? route = null,}) {
  return _then(_SelectRoute(
null == route ? _self.route : route // ignore: cast_nullable_to_non_nullable
as RouteModel,
  ));
}

/// Create a copy of RoutesEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RouteModelCopyWith<$Res> get route {
  
  return $RouteModelCopyWith<$Res>(_self.route, (value) {
    return _then(_self.copyWith(route: value));
  });
}
}

/// @nodoc


class _ClearSelection implements RoutesEvent {
  const _ClearSelection();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClearSelection);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'RoutesEvent.clearSelection()';
}


}




/// @nodoc
mixin _$RoutesState {

 List<RouteModel> get routes; bool get isLoading; String? get error; RouteModel? get selectedRoute;
/// Create a copy of RoutesState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoutesStateCopyWith<RoutesState> get copyWith => _$RoutesStateCopyWithImpl<RoutesState>(this as RoutesState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoutesState&&const DeepCollectionEquality().equals(other.routes, routes)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.error, error) || other.error == error)&&(identical(other.selectedRoute, selectedRoute) || other.selectedRoute == selectedRoute));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(routes),isLoading,error,selectedRoute);

@override
String toString() {
  return 'RoutesState(routes: $routes, isLoading: $isLoading, error: $error, selectedRoute: $selectedRoute)';
}


}

/// @nodoc
abstract mixin class $RoutesStateCopyWith<$Res>  {
  factory $RoutesStateCopyWith(RoutesState value, $Res Function(RoutesState) _then) = _$RoutesStateCopyWithImpl;
@useResult
$Res call({
 List<RouteModel> routes, bool isLoading, String? error, RouteModel? selectedRoute
});


$RouteModelCopyWith<$Res>? get selectedRoute;

}
/// @nodoc
class _$RoutesStateCopyWithImpl<$Res>
    implements $RoutesStateCopyWith<$Res> {
  _$RoutesStateCopyWithImpl(this._self, this._then);

  final RoutesState _self;
  final $Res Function(RoutesState) _then;

/// Create a copy of RoutesState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? routes = null,Object? isLoading = null,Object? error = freezed,Object? selectedRoute = freezed,}) {
  return _then(_self.copyWith(
routes: null == routes ? _self.routes : routes // ignore: cast_nullable_to_non_nullable
as List<RouteModel>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,selectedRoute: freezed == selectedRoute ? _self.selectedRoute : selectedRoute // ignore: cast_nullable_to_non_nullable
as RouteModel?,
  ));
}
/// Create a copy of RoutesState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RouteModelCopyWith<$Res>? get selectedRoute {
    if (_self.selectedRoute == null) {
    return null;
  }

  return $RouteModelCopyWith<$Res>(_self.selectedRoute!, (value) {
    return _then(_self.copyWith(selectedRoute: value));
  });
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<RouteModel> routes,  bool isLoading,  String? error,  RouteModel? selectedRoute)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RoutesState() when $default != null:
return $default(_that.routes,_that.isLoading,_that.error,_that.selectedRoute);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<RouteModel> routes,  bool isLoading,  String? error,  RouteModel? selectedRoute)  $default,) {final _that = this;
switch (_that) {
case _RoutesState():
return $default(_that.routes,_that.isLoading,_that.error,_that.selectedRoute);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<RouteModel> routes,  bool isLoading,  String? error,  RouteModel? selectedRoute)?  $default,) {final _that = this;
switch (_that) {
case _RoutesState() when $default != null:
return $default(_that.routes,_that.isLoading,_that.error,_that.selectedRoute);case _:
  return null;

}
}

}

/// @nodoc


class _RoutesState implements RoutesState {
  const _RoutesState({final  List<RouteModel> routes = const [], this.isLoading = false, this.error, this.selectedRoute}): _routes = routes;
  

 final  List<RouteModel> _routes;
@override@JsonKey() List<RouteModel> get routes {
  if (_routes is EqualUnmodifiableListView) return _routes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_routes);
}

@override@JsonKey() final  bool isLoading;
@override final  String? error;
@override final  RouteModel? selectedRoute;

/// Create a copy of RoutesState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RoutesStateCopyWith<_RoutesState> get copyWith => __$RoutesStateCopyWithImpl<_RoutesState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RoutesState&&const DeepCollectionEquality().equals(other._routes, _routes)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.error, error) || other.error == error)&&(identical(other.selectedRoute, selectedRoute) || other.selectedRoute == selectedRoute));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_routes),isLoading,error,selectedRoute);

@override
String toString() {
  return 'RoutesState(routes: $routes, isLoading: $isLoading, error: $error, selectedRoute: $selectedRoute)';
}


}

/// @nodoc
abstract mixin class _$RoutesStateCopyWith<$Res> implements $RoutesStateCopyWith<$Res> {
  factory _$RoutesStateCopyWith(_RoutesState value, $Res Function(_RoutesState) _then) = __$RoutesStateCopyWithImpl;
@override @useResult
$Res call({
 List<RouteModel> routes, bool isLoading, String? error, RouteModel? selectedRoute
});


@override $RouteModelCopyWith<$Res>? get selectedRoute;

}
/// @nodoc
class __$RoutesStateCopyWithImpl<$Res>
    implements _$RoutesStateCopyWith<$Res> {
  __$RoutesStateCopyWithImpl(this._self, this._then);

  final _RoutesState _self;
  final $Res Function(_RoutesState) _then;

/// Create a copy of RoutesState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? routes = null,Object? isLoading = null,Object? error = freezed,Object? selectedRoute = freezed,}) {
  return _then(_RoutesState(
routes: null == routes ? _self._routes : routes // ignore: cast_nullable_to_non_nullable
as List<RouteModel>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,selectedRoute: freezed == selectedRoute ? _self.selectedRoute : selectedRoute // ignore: cast_nullable_to_non_nullable
as RouteModel?,
  ));
}

/// Create a copy of RoutesState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RouteModelCopyWith<$Res>? get selectedRoute {
    if (_self.selectedRoute == null) {
    return null;
  }

  return $RouteModelCopyWith<$Res>(_self.selectedRoute!, (value) {
    return _then(_self.copyWith(selectedRoute: value));
  });
}
}

// dart format on
