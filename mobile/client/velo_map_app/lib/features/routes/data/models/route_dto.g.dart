// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RouteStage _$RouteStageFromJson(Map<String, dynamic> json) => _RouteStage(
  stage: (json['stage'] as num).toInt(),
  name: json['name'] as String,
  description: json['description'] as String,
  distanceKm: (json['distanceKm'] as num).toDouble(),
  elevationGain: (json['elevationGain'] as num).toDouble(),
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
      'coordinates': instance.coordinates,
    };

_RouteDto _$RouteDtoFromJson(Map<String, dynamic> json) => _RouteDto(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  distanceKm: (json['distanceKm'] as num).toDouble(),
  elevationGainM: (json['elevationGainM'] as num).toDouble(),
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
  cities:
      (json['cities'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  routeDescription: json['routeDescription'] as String? ?? '',
  fullName: json['fullName'] as String? ?? '',
  colorValue: (json['colorValue'] as num?)?.toInt() ?? 0xFF546E7A,
);

Map<String, dynamic> _$RouteDtoToJson(_RouteDto instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'distanceKm': instance.distanceKm,
  'elevationGainM': instance.elevationGainM,
  'routeNumber': instance.routeNumber,
  'coordinates': instance.coordinates,
  'stages': instance.stages,
  'cities': instance.cities,
  'routeDescription': instance.routeDescription,
  'fullName': instance.fullName,
  'colorValue': instance.colorValue,
};
