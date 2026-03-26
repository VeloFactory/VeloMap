import 'package:velo_map_app/features/routes/domain/models/route_stage_status.dart';

class RouteStageEntity {
  final int stage;
  final String name;
  final String description;
  final double distanceKm;
  final double elevationGain;
  final List<List<double>> coordinates;

  const RouteStageEntity({
    required this.stage,
    required this.name,
    required this.description,
    required this.distanceKm,
    required this.elevationGain,
    required this.coordinates,
  });

  String get formattedDistance => '${distanceKm.toStringAsFixed(1)} km';
  String get formattedElevation => '${elevationGain.toStringAsFixed(0)} m';

  /// Get the development status parsed from description
  RouteStageStatus get status => RouteStageStatus.fromDescription(description);
}
