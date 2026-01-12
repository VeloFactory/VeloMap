import 'package:velo_map_app/core/entities/geo_point.dart';
import 'package:velo_map_app/features/routes/data/models/route_difficulty_dto.dart';
import 'package:velo_map_app/features/routes/data/models/route_metrics_dto.dart';
import '../../domain/entities/route_entity.dart';

class RouteDto {
  final String id;
  final String name;
  final String? description;
  final String? difficulty;

  final int countries;
  final List<Map<String, dynamic>> path;
  final RouteMetricsDto metrics;

  final String? icon;
  final List<String> imageUrls;
  final List<RouteDto> subRoutes;

  const RouteDto({
    required this.id,
    required this.name,
    this.description,
    this.difficulty,
    required this.countries,
    required this.path,
    required this.metrics,
    this.icon,
    this.imageUrls = const [],
    this.subRoutes = const [],
  });

  factory RouteDto.fromJson(Map<String, dynamic> json) => RouteDto(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String?,
    difficulty: json['difficulty'] as String?,
    countries: json['countries'] as int,
    path: List<Map<String, dynamic>>.from(json['path'] as List),
    metrics: RouteMetricsDto.fromJson(json['metrics'] as Map<String, dynamic>),
    icon: json['icon'] as String?,
    imageUrls: List<String>.from(json['imageUrls'] as List? ?? const []),
    subRoutes: (json['subRoutes'] as List? ?? const [])
        .map((e) => RouteDto.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    if (description != null) 'description': description,
    if (difficulty != null) 'difficulty': difficulty,
    'countries': countries,
    'path': path,
    'metrics': metrics.toJson(),
    if (icon != null) 'icon': icon,
    if (imageUrls.isNotEmpty) 'imageUrls': imageUrls,
    if (subRoutes.isNotEmpty)
      'subRoutes': subRoutes.map((e) => e.toJson()).toList(),
  };

  RouteEntity toEntity() => RouteEntity(
    id: id,
    name: name,
    description: description,
    difficulty: RouteDifficultyDto.fromJson(difficulty),
    countries: countries,
    path: path.map(GeoPoint.fromJson).toList(),
    metrics: metrics.toEntity(),
    icon: icon,
    imageUrls: imageUrls,
    subRoutes: subRoutes.map((e) => e.toEntity()).toList(),
  );

  factory RouteDto.fromEntity(RouteEntity entity) => RouteDto(
    id: entity.id,
    name: entity.name,
    description: entity.description,
    difficulty: entity.difficulty?.toJson(),
    countries: entity.countries,
    path: entity.path.map((e) => e.toJson()).toList(),
    metrics: RouteMetricsDto.fromEntity(entity.metrics),
    icon: entity.icon,
    imageUrls: entity.imageUrls,
    subRoutes: entity.subRoutes.map(RouteDto.fromEntity).toList(),
  );
}
