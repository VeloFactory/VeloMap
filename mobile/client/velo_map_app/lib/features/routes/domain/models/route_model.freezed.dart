// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'route_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RouteStage {

 int get stage; String get name; String get description; double get distanceKm; double get elevationGain; String get difficulty; List<List<double>> get coordinates;
/// Create a copy of RouteStage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RouteStageCopyWith<RouteStage> get copyWith => _$RouteStageCopyWithImpl<RouteStage>(this as RouteStage, _$identity);

  /// Serializes this RouteStage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RouteStage&&(identical(other.stage, stage) || other.stage == stage)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.distanceKm, distanceKm) || other.distanceKm == distanceKm)&&(identical(other.elevationGain, elevationGain) || other.elevationGain == elevationGain)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&const DeepCollectionEquality().equals(other.coordinates, coordinates));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,stage,name,description,distanceKm,elevationGain,difficulty,const DeepCollectionEquality().hash(coordinates));

@override
String toString() {
  return 'RouteStage(stage: $stage, name: $name, description: $description, distanceKm: $distanceKm, elevationGain: $elevationGain, difficulty: $difficulty, coordinates: $coordinates)';
}


}

/// @nodoc
abstract mixin class $RouteStageCopyWith<$Res>  {
  factory $RouteStageCopyWith(RouteStage value, $Res Function(RouteStage) _then) = _$RouteStageCopyWithImpl;
@useResult
$Res call({
 int stage, String name, String description, double distanceKm, double elevationGain, String difficulty, List<List<double>> coordinates
});




}
/// @nodoc
class _$RouteStageCopyWithImpl<$Res>
    implements $RouteStageCopyWith<$Res> {
  _$RouteStageCopyWithImpl(this._self, this._then);

  final RouteStage _self;
  final $Res Function(RouteStage) _then;

/// Create a copy of RouteStage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? stage = null,Object? name = null,Object? description = null,Object? distanceKm = null,Object? elevationGain = null,Object? difficulty = null,Object? coordinates = null,}) {
  return _then(_self.copyWith(
stage: null == stage ? _self.stage : stage // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,distanceKm: null == distanceKm ? _self.distanceKm : distanceKm // ignore: cast_nullable_to_non_nullable
as double,elevationGain: null == elevationGain ? _self.elevationGain : elevationGain // ignore: cast_nullable_to_non_nullable
as double,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as String,coordinates: null == coordinates ? _self.coordinates : coordinates // ignore: cast_nullable_to_non_nullable
as List<List<double>>,
  ));
}

}


/// Adds pattern-matching-related methods to [RouteStage].
extension RouteStagePatterns on RouteStage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RouteStage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RouteStage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RouteStage value)  $default,){
final _that = this;
switch (_that) {
case _RouteStage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RouteStage value)?  $default,){
final _that = this;
switch (_that) {
case _RouteStage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int stage,  String name,  String description,  double distanceKm,  double elevationGain,  String difficulty,  List<List<double>> coordinates)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RouteStage() when $default != null:
return $default(_that.stage,_that.name,_that.description,_that.distanceKm,_that.elevationGain,_that.difficulty,_that.coordinates);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int stage,  String name,  String description,  double distanceKm,  double elevationGain,  String difficulty,  List<List<double>> coordinates)  $default,) {final _that = this;
switch (_that) {
case _RouteStage():
return $default(_that.stage,_that.name,_that.description,_that.distanceKm,_that.elevationGain,_that.difficulty,_that.coordinates);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int stage,  String name,  String description,  double distanceKm,  double elevationGain,  String difficulty,  List<List<double>> coordinates)?  $default,) {final _that = this;
switch (_that) {
case _RouteStage() when $default != null:
return $default(_that.stage,_that.name,_that.description,_that.distanceKm,_that.elevationGain,_that.difficulty,_that.coordinates);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RouteStage extends RouteStage {
  const _RouteStage({required this.stage, required this.name, required this.description, required this.distanceKm, required this.elevationGain, required this.difficulty, required final  List<List<double>> coordinates}): _coordinates = coordinates,super._();
  factory _RouteStage.fromJson(Map<String, dynamic> json) => _$RouteStageFromJson(json);

@override final  int stage;
@override final  String name;
@override final  String description;
@override final  double distanceKm;
@override final  double elevationGain;
@override final  String difficulty;
 final  List<List<double>> _coordinates;
@override List<List<double>> get coordinates {
  if (_coordinates is EqualUnmodifiableListView) return _coordinates;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_coordinates);
}


/// Create a copy of RouteStage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RouteStageCopyWith<_RouteStage> get copyWith => __$RouteStageCopyWithImpl<_RouteStage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RouteStageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RouteStage&&(identical(other.stage, stage) || other.stage == stage)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.distanceKm, distanceKm) || other.distanceKm == distanceKm)&&(identical(other.elevationGain, elevationGain) || other.elevationGain == elevationGain)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&const DeepCollectionEquality().equals(other._coordinates, _coordinates));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,stage,name,description,distanceKm,elevationGain,difficulty,const DeepCollectionEquality().hash(_coordinates));

@override
String toString() {
  return 'RouteStage(stage: $stage, name: $name, description: $description, distanceKm: $distanceKm, elevationGain: $elevationGain, difficulty: $difficulty, coordinates: $coordinates)';
}


}

/// @nodoc
abstract mixin class _$RouteStageCopyWith<$Res> implements $RouteStageCopyWith<$Res> {
  factory _$RouteStageCopyWith(_RouteStage value, $Res Function(_RouteStage) _then) = __$RouteStageCopyWithImpl;
@override @useResult
$Res call({
 int stage, String name, String description, double distanceKm, double elevationGain, String difficulty, List<List<double>> coordinates
});




}
/// @nodoc
class __$RouteStageCopyWithImpl<$Res>
    implements _$RouteStageCopyWith<$Res> {
  __$RouteStageCopyWithImpl(this._self, this._then);

  final _RouteStage _self;
  final $Res Function(_RouteStage) _then;

/// Create a copy of RouteStage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? stage = null,Object? name = null,Object? description = null,Object? distanceKm = null,Object? elevationGain = null,Object? difficulty = null,Object? coordinates = null,}) {
  return _then(_RouteStage(
stage: null == stage ? _self.stage : stage // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,distanceKm: null == distanceKm ? _self.distanceKm : distanceKm // ignore: cast_nullable_to_non_nullable
as double,elevationGain: null == elevationGain ? _self.elevationGain : elevationGain // ignore: cast_nullable_to_non_nullable
as double,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as String,coordinates: null == coordinates ? _self._coordinates : coordinates // ignore: cast_nullable_to_non_nullable
as List<List<double>>,
  ));
}


}


/// @nodoc
mixin _$RouteModel {

 String get id; String get name; String get description; double get distanceKm; double get elevationGainM; String get difficulty; int get routeNumber; List<List<double>> get coordinates; List<RouteStage> get stages;
/// Create a copy of RouteModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RouteModelCopyWith<RouteModel> get copyWith => _$RouteModelCopyWithImpl<RouteModel>(this as RouteModel, _$identity);

  /// Serializes this RouteModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RouteModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.distanceKm, distanceKm) || other.distanceKm == distanceKm)&&(identical(other.elevationGainM, elevationGainM) || other.elevationGainM == elevationGainM)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.routeNumber, routeNumber) || other.routeNumber == routeNumber)&&const DeepCollectionEquality().equals(other.coordinates, coordinates)&&const DeepCollectionEquality().equals(other.stages, stages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,distanceKm,elevationGainM,difficulty,routeNumber,const DeepCollectionEquality().hash(coordinates),const DeepCollectionEquality().hash(stages));

@override
String toString() {
  return 'RouteModel(id: $id, name: $name, description: $description, distanceKm: $distanceKm, elevationGainM: $elevationGainM, difficulty: $difficulty, routeNumber: $routeNumber, coordinates: $coordinates, stages: $stages)';
}


}

/// @nodoc
abstract mixin class $RouteModelCopyWith<$Res>  {
  factory $RouteModelCopyWith(RouteModel value, $Res Function(RouteModel) _then) = _$RouteModelCopyWithImpl;
@useResult
$Res call({
 String id, String name, String description, double distanceKm, double elevationGainM, String difficulty, int routeNumber, List<List<double>> coordinates, List<RouteStage> stages
});




}
/// @nodoc
class _$RouteModelCopyWithImpl<$Res>
    implements $RouteModelCopyWith<$Res> {
  _$RouteModelCopyWithImpl(this._self, this._then);

  final RouteModel _self;
  final $Res Function(RouteModel) _then;

/// Create a copy of RouteModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = null,Object? distanceKm = null,Object? elevationGainM = null,Object? difficulty = null,Object? routeNumber = null,Object? coordinates = null,Object? stages = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,distanceKm: null == distanceKm ? _self.distanceKm : distanceKm // ignore: cast_nullable_to_non_nullable
as double,elevationGainM: null == elevationGainM ? _self.elevationGainM : elevationGainM // ignore: cast_nullable_to_non_nullable
as double,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as String,routeNumber: null == routeNumber ? _self.routeNumber : routeNumber // ignore: cast_nullable_to_non_nullable
as int,coordinates: null == coordinates ? _self.coordinates : coordinates // ignore: cast_nullable_to_non_nullable
as List<List<double>>,stages: null == stages ? _self.stages : stages // ignore: cast_nullable_to_non_nullable
as List<RouteStage>,
  ));
}

}


/// Adds pattern-matching-related methods to [RouteModel].
extension RouteModelPatterns on RouteModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RouteModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RouteModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RouteModel value)  $default,){
final _that = this;
switch (_that) {
case _RouteModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RouteModel value)?  $default,){
final _that = this;
switch (_that) {
case _RouteModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String description,  double distanceKm,  double elevationGainM,  String difficulty,  int routeNumber,  List<List<double>> coordinates,  List<RouteStage> stages)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RouteModel() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.distanceKm,_that.elevationGainM,_that.difficulty,_that.routeNumber,_that.coordinates,_that.stages);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String description,  double distanceKm,  double elevationGainM,  String difficulty,  int routeNumber,  List<List<double>> coordinates,  List<RouteStage> stages)  $default,) {final _that = this;
switch (_that) {
case _RouteModel():
return $default(_that.id,_that.name,_that.description,_that.distanceKm,_that.elevationGainM,_that.difficulty,_that.routeNumber,_that.coordinates,_that.stages);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String description,  double distanceKm,  double elevationGainM,  String difficulty,  int routeNumber,  List<List<double>> coordinates,  List<RouteStage> stages)?  $default,) {final _that = this;
switch (_that) {
case _RouteModel() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.distanceKm,_that.elevationGainM,_that.difficulty,_that.routeNumber,_that.coordinates,_that.stages);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RouteModel extends RouteModel {
  const _RouteModel({required this.id, required this.name, required this.description, required this.distanceKm, required this.elevationGainM, required this.difficulty, required this.routeNumber, required final  List<List<double>> coordinates, final  List<RouteStage> stages = const []}): _coordinates = coordinates,_stages = stages,super._();
  factory _RouteModel.fromJson(Map<String, dynamic> json) => _$RouteModelFromJson(json);

@override final  String id;
@override final  String name;
@override final  String description;
@override final  double distanceKm;
@override final  double elevationGainM;
@override final  String difficulty;
@override final  int routeNumber;
 final  List<List<double>> _coordinates;
@override List<List<double>> get coordinates {
  if (_coordinates is EqualUnmodifiableListView) return _coordinates;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_coordinates);
}

 final  List<RouteStage> _stages;
@override@JsonKey() List<RouteStage> get stages {
  if (_stages is EqualUnmodifiableListView) return _stages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_stages);
}


/// Create a copy of RouteModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RouteModelCopyWith<_RouteModel> get copyWith => __$RouteModelCopyWithImpl<_RouteModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RouteModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RouteModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.distanceKm, distanceKm) || other.distanceKm == distanceKm)&&(identical(other.elevationGainM, elevationGainM) || other.elevationGainM == elevationGainM)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.routeNumber, routeNumber) || other.routeNumber == routeNumber)&&const DeepCollectionEquality().equals(other._coordinates, _coordinates)&&const DeepCollectionEquality().equals(other._stages, _stages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,distanceKm,elevationGainM,difficulty,routeNumber,const DeepCollectionEquality().hash(_coordinates),const DeepCollectionEquality().hash(_stages));

@override
String toString() {
  return 'RouteModel(id: $id, name: $name, description: $description, distanceKm: $distanceKm, elevationGainM: $elevationGainM, difficulty: $difficulty, routeNumber: $routeNumber, coordinates: $coordinates, stages: $stages)';
}


}

/// @nodoc
abstract mixin class _$RouteModelCopyWith<$Res> implements $RouteModelCopyWith<$Res> {
  factory _$RouteModelCopyWith(_RouteModel value, $Res Function(_RouteModel) _then) = __$RouteModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String description, double distanceKm, double elevationGainM, String difficulty, int routeNumber, List<List<double>> coordinates, List<RouteStage> stages
});




}
/// @nodoc
class __$RouteModelCopyWithImpl<$Res>
    implements _$RouteModelCopyWith<$Res> {
  __$RouteModelCopyWithImpl(this._self, this._then);

  final _RouteModel _self;
  final $Res Function(_RouteModel) _then;

/// Create a copy of RouteModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = null,Object? distanceKm = null,Object? elevationGainM = null,Object? difficulty = null,Object? routeNumber = null,Object? coordinates = null,Object? stages = null,}) {
  return _then(_RouteModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,distanceKm: null == distanceKm ? _self.distanceKm : distanceKm // ignore: cast_nullable_to_non_nullable
as double,elevationGainM: null == elevationGainM ? _self.elevationGainM : elevationGainM // ignore: cast_nullable_to_non_nullable
as double,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as String,routeNumber: null == routeNumber ? _self.routeNumber : routeNumber // ignore: cast_nullable_to_non_nullable
as int,coordinates: null == coordinates ? _self._coordinates : coordinates // ignore: cast_nullable_to_non_nullable
as List<List<double>>,stages: null == stages ? _self._stages : stages // ignore: cast_nullable_to_non_nullable
as List<RouteStage>,
  ));
}


}

// dart format on
