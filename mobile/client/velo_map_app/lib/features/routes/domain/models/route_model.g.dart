// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RouteStage _$RouteStageFromJson(Map<String, dynamic> json) => _RouteStage(
  stage: (json['stage'] as num).toInt(),
  name: json['name'] as String,
  description: json['description'] as String,
  distanceKm: (json['distanceKm'] as num).toDouble(),
  elevationGain: (json['elevationGain'] as num).toDouble(),
  difficulty: json['difficulty'] as String,
  coordinates: (json['coordinates'] as List<dynamic>)
      .map(
        (e) => (e as List<dynamic>).map((e) => (e as num).toDouble()).toList(),
      )
      .toList(),
);

Map<String, dynamic> _$RouteStageToJson(_RouteStage instance) =>
    <String, dynamic>{
      'stage': instance.stage,
      'name': instance.name,
      'description': instance.description,
      'distanceKm': instance.distanceKm,
      'elevationGain': instance.elevationGain,
      'difficulty': instance.difficulty,
      'coordinates': instance.coordinates,
    };

_RouteModel _$RouteModelFromJson(Map<String, dynamic> json) => _RouteModel(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  distanceKm: (json['distanceKm'] as num).toDouble(),
  elevationGainM: (json['elevationGainM'] as num).toDouble(),
  difficulty: json['difficulty'] as String,
  routeNumber: (json['routeNumber'] as num).toInt(),
  coordinates: (json['coordinates'] as List<dynamic>)
      .map(
        (e) => (e as List<dynamic>).map((e) => (e as num).toDouble()).toList(),
      )
      .toList(),
  stages:
      (json['stages'] as List<dynamic>?)
          ?.map((e) => RouteStage.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$RouteModelToJson(_RouteModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'distanceKm': instance.distanceKm,
      'elevationGainM': instance.elevationGainM,
      'difficulty': instance.difficulty,
      'routeNumber': instance.routeNumber,
      'coordinates': instance.coordinates,
      'stages': instance.stages,
    };
