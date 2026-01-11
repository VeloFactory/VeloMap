import 'package:freezed_annotation/freezed_annotation.dart';

part 'route_model.freezed.dart';
part 'route_model.g.dart';

@freezed
sealed class RouteModel with _$RouteModel {
  const RouteModel._();

  const factory RouteModel({
    required String id,
    required String name,
    required String description,
    required double distanceKm,
    required int durationMinutes,
    required String difficulty,
    required String surface,
    required List<List<double>> coordinates,
  }) = _RouteModel;

  factory RouteModel.fromJson(Map<String, dynamic> json) =>
      _$RouteModelFromJson(json);

  /// Factory to parse a GeoJSON Feature into RouteModel
  factory RouteModel.fromGeoJson(Map<String, dynamic> geoJson) {
    final properties = geoJson['properties'] as Map<String, dynamic>;
    final geometry = geoJson['geometry'] as Map<String, dynamic>;
    final rawCoords = geometry['coordinates'] as List<dynamic>;

    final coordinates = rawCoords
        .map((coord) => (coord as List<dynamic>)
            .map((c) => (c as num).toDouble())
            .toList())
        .toList();

    return RouteModel(
      id: properties['id'] as String,
      name: properties['name'] as String,
      description: properties['description'] as String,
      distanceKm: (properties['distance_km'] as num).toDouble(),
      durationMinutes: (properties['duration_minutes'] as num).toInt(),
      difficulty: properties['difficulty'] as String,
      surface: properties['surface'] as String,
      coordinates: coordinates,
    );
  }

  /// Returns duration as formatted string (e.g., "1h 30m" or "45m")
  String get formattedDuration {
    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;
    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }

  /// Returns distance as formatted string (e.g., "12.5 km")
  String get formattedDistance => '${distanceKm.toStringAsFixed(1)} km';

  /// Returns the center point of the route for initial map positioning
  List<double> get centerPoint {
    if (coordinates.isEmpty) return [0.0, 0.0];

    double sumLng = 0;
    double sumLat = 0;

    for (final coord in coordinates) {
      sumLng += coord[0];
      sumLat += coord[1];
    }

    return [sumLng / coordinates.length, sumLat / coordinates.length];
  }

  /// Returns bounding box [minLng, minLat, maxLng, maxLat]
  List<double> get boundingBox {
    if (coordinates.isEmpty) return [0, 0, 0, 0];

    double minLng = coordinates.first[0];
    double maxLng = coordinates.first[0];
    double minLat = coordinates.first[1];
    double maxLat = coordinates.first[1];

    for (final coord in coordinates) {
      if (coord[0] < minLng) minLng = coord[0];
      if (coord[0] > maxLng) maxLng = coord[0];
      if (coord[1] < minLat) minLat = coord[1];
      if (coord[1] > maxLat) maxLat = coord[1];
    }

    return [minLng, minLat, maxLng, maxLat];
  }
}
