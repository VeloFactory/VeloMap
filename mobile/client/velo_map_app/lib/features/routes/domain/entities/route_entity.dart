import 'route_stage_entity.dart';

class RouteEntity {
  final String id;
  final String name;
  final String description;
  final double distanceKm;
  final double elevationGainM;
  final String difficulty;
  final int routeNumber;
  final List<List<double>> coordinates;
  final List<RouteStageEntity> stages;
  final List<String> cities;

  const RouteEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.distanceKm,
    required this.elevationGainM,
    required this.difficulty,
    required this.routeNumber,
    required this.coordinates,
    this.stages = const [],
    this.cities = const [],
  });

  String get formattedElevation => '${elevationGainM.toStringAsFixed(0)} m';
  String get formattedDistance => '${distanceKm.toStringAsFixed(1)} km';

  /// Center point [lng, lat]
  List<double> get centerPoint {
    if (coordinates.isEmpty) return const [0.0, 0.0];

    double sumLng = 0;
    double sumLat = 0;

    for (final coord in coordinates) {
      if (coord.length < 2) continue;
      sumLng += coord[0];
      sumLat += coord[1];
    }

    final count = coordinates.where((c) => c.length >= 2).length;
    if (count == 0) return const [0.0, 0.0];

    return [sumLng / count, sumLat / count];
  }

  /// Bounding box [minLng, minLat, maxLng, maxLat]
  List<double> get boundingBox {
    final valid = coordinates.where((c) => c.length >= 2).toList();
    if (valid.isEmpty) return const [0, 0, 0, 0];

    double minLng = valid.first[0];
    double maxLng = valid.first[0];
    double minLat = valid.first[1];
    double maxLat = valid.first[1];

    for (final c in valid) {
      if (c[0] < minLng) minLng = c[0];
      if (c[0] > maxLng) maxLng = c[0];
      if (c[1] < minLat) minLat = c[1];
      if (c[1] > maxLat) maxLat = c[1];
    }

    return [minLng, minLat, maxLng, maxLat];
  }
}
