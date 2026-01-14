// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'routes_event.dart';

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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( Load value)?  load,TResult Function( SelectRoute value)?  selectRoute,TResult Function( ClearSelection value)?  clearSelection,TResult Function( SelectStage value)?  selectStage,TResult Function( ClearStageSelection value)?  clearStageSelection,required TResult orElse(),}){
final _that = this;
switch (_that) {
case Load() when load != null:
return load(_that);case SelectRoute() when selectRoute != null:
return selectRoute(_that);case ClearSelection() when clearSelection != null:
return clearSelection(_that);case SelectStage() when selectStage != null:
return selectStage(_that);case ClearStageSelection() when clearStageSelection != null:
return clearStageSelection(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( Load value)  load,required TResult Function( SelectRoute value)  selectRoute,required TResult Function( ClearSelection value)  clearSelection,required TResult Function( SelectStage value)  selectStage,required TResult Function( ClearStageSelection value)  clearStageSelection,}){
final _that = this;
switch (_that) {
case Load():
return load(_that);case SelectRoute():
return selectRoute(_that);case ClearSelection():
return clearSelection(_that);case SelectStage():
return selectStage(_that);case ClearStageSelection():
return clearStageSelection(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( Load value)?  load,TResult? Function( SelectRoute value)?  selectRoute,TResult? Function( ClearSelection value)?  clearSelection,TResult? Function( SelectStage value)?  selectStage,TResult? Function( ClearStageSelection value)?  clearStageSelection,}){
final _that = this;
switch (_that) {
case Load() when load != null:
return load(_that);case SelectRoute() when selectRoute != null:
return selectRoute(_that);case ClearSelection() when clearSelection != null:
return clearSelection(_that);case SelectStage() when selectStage != null:
return selectStage(_that);case ClearStageSelection() when clearStageSelection != null:
return clearStageSelection(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  load,TResult Function( RouteEntity route)?  selectRoute,TResult Function()?  clearSelection,TResult Function( RouteStageEntity stage)?  selectStage,TResult Function()?  clearStageSelection,required TResult orElse(),}) {final _that = this;
switch (_that) {
case Load() when load != null:
return load();case SelectRoute() when selectRoute != null:
return selectRoute(_that.route);case ClearSelection() when clearSelection != null:
return clearSelection();case SelectStage() when selectStage != null:
return selectStage(_that.stage);case ClearStageSelection() when clearStageSelection != null:
return clearStageSelection();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  load,required TResult Function( RouteEntity route)  selectRoute,required TResult Function()  clearSelection,required TResult Function( RouteStageEntity stage)  selectStage,required TResult Function()  clearStageSelection,}) {final _that = this;
switch (_that) {
case Load():
return load();case SelectRoute():
return selectRoute(_that.route);case ClearSelection():
return clearSelection();case SelectStage():
return selectStage(_that.stage);case ClearStageSelection():
return clearStageSelection();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  load,TResult? Function( RouteEntity route)?  selectRoute,TResult? Function()?  clearSelection,TResult? Function( RouteStageEntity stage)?  selectStage,TResult? Function()?  clearStageSelection,}) {final _that = this;
switch (_that) {
case Load() when load != null:
return load();case SelectRoute() when selectRoute != null:
return selectRoute(_that.route);case ClearSelection() when clearSelection != null:
return clearSelection();case SelectStage() when selectStage != null:
return selectStage(_that.stage);case ClearStageSelection() when clearStageSelection != null:
return clearStageSelection();case _:
  return null;

}
}

}

/// @nodoc


class Load implements RoutesEvent {
  const Load();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Load);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'RoutesEvent.load()';
}


}




/// @nodoc


class SelectRoute implements RoutesEvent {
  const SelectRoute(this.route);
  

 final  RouteEntity route;

/// Create a copy of RoutesEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SelectRouteCopyWith<SelectRoute> get copyWith => _$SelectRouteCopyWithImpl<SelectRoute>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SelectRoute&&(identical(other.route, route) || other.route == route));
}


@override
int get hashCode => Object.hash(runtimeType,route);

@override
String toString() {
  return 'RoutesEvent.selectRoute(route: $route)';
}


}

/// @nodoc
abstract mixin class $SelectRouteCopyWith<$Res> implements $RoutesEventCopyWith<$Res> {
  factory $SelectRouteCopyWith(SelectRoute value, $Res Function(SelectRoute) _then) = _$SelectRouteCopyWithImpl;
@useResult
$Res call({
 RouteEntity route
});




}
/// @nodoc
class _$SelectRouteCopyWithImpl<$Res>
    implements $SelectRouteCopyWith<$Res> {
  _$SelectRouteCopyWithImpl(this._self, this._then);

  final SelectRoute _self;
  final $Res Function(SelectRoute) _then;

/// Create a copy of RoutesEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? route = null,}) {
  return _then(SelectRoute(
null == route ? _self.route : route // ignore: cast_nullable_to_non_nullable
as RouteEntity,
  ));
}


}

/// @nodoc


class ClearSelection implements RoutesEvent {
  const ClearSelection();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClearSelection);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'RoutesEvent.clearSelection()';
}


}




/// @nodoc


class SelectStage implements RoutesEvent {
  const SelectStage(this.stage);
  

 final  RouteStageEntity stage;

/// Create a copy of RoutesEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SelectStageCopyWith<SelectStage> get copyWith => _$SelectStageCopyWithImpl<SelectStage>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SelectStage&&(identical(other.stage, stage) || other.stage == stage));
}


@override
int get hashCode => Object.hash(runtimeType,stage);

@override
String toString() {
  return 'RoutesEvent.selectStage(stage: $stage)';
}


}

/// @nodoc
abstract mixin class $SelectStageCopyWith<$Res> implements $RoutesEventCopyWith<$Res> {
  factory $SelectStageCopyWith(SelectStage value, $Res Function(SelectStage) _then) = _$SelectStageCopyWithImpl;
@useResult
$Res call({
 RouteStageEntity stage
});




}
/// @nodoc
class _$SelectStageCopyWithImpl<$Res>
    implements $SelectStageCopyWith<$Res> {
  _$SelectStageCopyWithImpl(this._self, this._then);

  final SelectStage _self;
  final $Res Function(SelectStage) _then;

/// Create a copy of RoutesEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? stage = null,}) {
  return _then(SelectStage(
null == stage ? _self.stage : stage // ignore: cast_nullable_to_non_nullable
as RouteStageEntity,
  ));
}


}

/// @nodoc


class ClearStageSelection implements RoutesEvent {
  const ClearStageSelection();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClearStageSelection);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'RoutesEvent.clearStageSelection()';
}


}




// dart format on
