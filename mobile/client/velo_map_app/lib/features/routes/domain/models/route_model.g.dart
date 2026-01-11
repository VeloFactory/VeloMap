// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RouteModel _$RouteModelFromJson(Map<String, dynamic> json) => _RouteModel(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  distanceKm: (json['distanceKm'] as num).toDouble(),
  durationMinutes: (json['durationMinutes'] as num).toInt(),
  difficulty: json['difficulty'] as String,
  surface: json['surface'] as String,
  coordinates: (json['coordinates'] as List<dynamic>)
      .map(
        (e) => (e as List<dynamic>).map((e) => (e as num).toDouble()).toList(),
      )
      .toList(),
);

Map<String, dynamic> _$RouteModelToJson(_RouteModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'distanceKm': instance.distanceKm,
      'durationMinutes': instance.durationMinutes,
      'difficulty': instance.difficulty,
      'surface': instance.surface,
      'coordinates': instance.coordinates,
    };
