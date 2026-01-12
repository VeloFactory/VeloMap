import 'package:velo_map_app/features/routes/domain/entities/route_metrics_entity.dart';

class RouteMetricsDto {
  final int distance;
  final int elevationGain;
  final int elevationLoss;
  final int? estimatedTimeMin;

  const RouteMetricsDto({
    required this.distance,
    required this.elevationGain,
    required this.elevationLoss,
    this.estimatedTimeMin,
  });

  factory RouteMetricsDto.fromJson(Map<String, dynamic> json) =>
      RouteMetricsDto(
        distance: json['distance'] as int,
        elevationGain: json['elevationGain'] as int,
        elevationLoss: json['elevationLoss'] as int,
        estimatedTimeMin: json['estimatedTimeMin'] as int?,
      );

  Map<String, dynamic> toJson() => {
    'distance': distance,
    'elevationGain': elevationGain,
    'elevationLoss': elevationLoss,
    if (estimatedTimeMin != null) 'estimatedTimeMin': estimatedTimeMin,
  };

  RouteMetricsEntity toEntity() => RouteMetricsEntity(
    distance: distance,
    elevationGain: elevationGain,
    elevationLoss: elevationLoss,
    estimatedTimeMin: estimatedTimeMin,
  );

  factory RouteMetricsDto.fromEntity(RouteMetricsEntity entity) =>
      RouteMetricsDto(
        distance: entity.distance,
        elevationGain: entity.elevationGain,
        elevationLoss: entity.elevationLoss,
        estimatedTimeMin: entity.estimatedTimeMin,
      );
}
