import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:velo_map_app/features/routes/domain/entities/route_entity.dart';
import 'package:velo_map_app/features/routes/domain/entities/route_stage_entity.dart';
import 'package:velo_map_app/features/routes/domain/services/route_color_resolver.dart';

part 'route_dto.freezed.dart';
part 'route_dto.g.dart';

/// Model for a route stage (segment)
@freezed
sealed class RouteStage with _$RouteStage {
  const RouteStage._();

  const factory RouteStage({
    required int stage,
    required String name,
    required String description,
    required double distanceKm,
    required double elevationGain,
    required String difficulty,
    required List<List<double>> coordinates,
  }) = _RouteStage;

  factory RouteStage.fromJson(Map<String, dynamic> json) =>
      _$RouteStageFromJson(json);

  /// Returns distance as formatted string (e.g., "12.5 km")
  String get formattedDistance => '${distanceKm.toStringAsFixed(1)} km';

  /// Returns elevation as formatted string (e.g., "245 m")
  String get formattedElevation => '${elevationGain.toStringAsFixed(0)} m';

  RouteStageEntity toEntity() {
    return RouteStageEntity(
      stage: stage,
      name: name,
      description: description,
      distanceKm: distanceKm,
      elevationGain: elevationGain,
      difficulty: difficulty,
      coordinates: coordinates,
    );
  }
}

@freezed
sealed class RouteDto with _$RouteDto {
  const RouteDto._();

  const factory RouteDto({
    required String id,
    required String name,
    required String description,
    required double distanceKm,
    required double elevationGainM,
    required String difficulty,
    required int routeNumber,
    required List<List<double>> coordinates,
    @Default([]) List<RouteStage> stages,
    @Default([]) List<String> cities,
  }) = _RouteDto;

  factory RouteDto.fromJson(Map<String, dynamic> json) =>
      _$RouteDtoFromJson(json);

  /// Factory to parse a GeoJSON Feature or FeatureCollection into RouteModel
  factory RouteDto.fromGeoJson(Map<String, dynamic> geoJson) {
    final type = geoJson['type'] as String;

    // Handle FeatureCollection (multi-stage routes)
    if (type == 'FeatureCollection') {
      return _fromFeatureCollection(geoJson);
    }

    // Handle single Feature (simple routes)
    return _fromSingleFeature(geoJson);
  }

  /// Parse a single Feature GeoJSON
  static RouteDto _fromSingleFeature(Map<String, dynamic> geoJson) {
    final properties = geoJson['properties'] as Map<String, dynamic>;
    final geometry = geoJson['geometry'] as Map<String, dynamic>;

    final coordinates = _extractCoordinates(geometry);

    // Calculate elevation gain from coordinates (if elevation data exists)
    final elevationGain = _calculateElevationGain(coordinates);

    // Parse cities list
    final citiesList =
        (properties['cities'] as List<dynamic>?)
            ?.map((c) => c as String)
            .toList() ??
        <String>[];

    return RouteDto(
      id: properties['id'] as String,
      name: properties['name'] as String,
      description: properties['description'] as String,
      distanceKm: (properties['distance_km'] as num).toDouble(),
      elevationGainM: elevationGain,
      difficulty: properties['difficulty'] as String,
      routeNumber: (properties['route_number'] as num).toInt(),
      coordinates: coordinates,
      cities: citiesList,
    );
  }

  /// Parse a FeatureCollection GeoJSON (multi-stage routes)
  static RouteDto _fromFeatureCollection(Map<String, dynamic> geoJson) {
    final properties = geoJson['properties'] as Map<String, dynamic>;
    final features = geoJson['features'] as List<dynamic>;

    // Merge coordinates from all features, handling MultiLineString gaps
    final allCoordinates = <List<double>>[];
    final stages = <RouteStage>[];

    for (int i = 0; i < features.length; i++) {
      final feature = features[i] as Map<String, dynamic>;
      final featureProps = feature['properties'] as Map<String, dynamic>;
      final geometry = feature['geometry'] as Map<String, dynamic>;

      // Use _extractCoordinates to handle both LineString and MultiLineString
      final stageCoords = _extractCoordinates(geometry);

      // Create RouteStage
      stages.add(
        RouteStage(
          stage: (featureProps['stage'] as num).toInt(),
          name: featureProps['name'] as String,
          description: featureProps['description'] as String,
          distanceKm: (featureProps['distance_km'] as num).toDouble(),
          elevationGain: (featureProps['elevation_gain'] as num).toDouble(),
          difficulty: featureProps['difficulty'] as String,
          coordinates: stageCoords,
        ),
      );

      // Find valid (non-empty) coordinates for boundary matching
      final lastValid = allCoordinates.isNotEmpty
          ? allCoordinates.lastWhere((c) => c.isNotEmpty, orElse: () => <double>[])
          : <double>[];
      final firstValid = stageCoords.isNotEmpty
          ? stageCoords.firstWhere((c) => c.isNotEmpty, orElse: () => <double>[])
          : <double>[];

      // Check if this stage connects to the previous one
      final isConnected = i == 0 ||
          (lastValid.isNotEmpty &&
              firstValid.isNotEmpty &&
              _coordinatesAreClose(lastValid, firstValid));

      // Add gap marker if stages are not connected (e.g., ferry crossing)
      if (i > 0 && !isConnected) {
        allCoordinates.add(<double>[]); // Gap marker
      }

      // Skip first coordinate if it exactly matches the last one from previous stage
      final shouldSkipFirst = i > 0 &&
          lastValid.isNotEmpty &&
          firstValid.isNotEmpty &&
          _coordinatesMatch(lastValid, firstValid);

      if (shouldSkipFirst && stageCoords.isNotEmpty) {
        allCoordinates.addAll(stageCoords.sublist(1));
      } else {
        allCoordinates.addAll(stageCoords);
      }
    }

    // Calculate elevation gain from merged coordinates
    final elevationGain = _calculateElevationGain(allCoordinates);

    // Parse cities list
    final citiesList =
        (properties['cities'] as List<dynamic>?)
            ?.map((c) => c as String)
            .toList() ??
        <String>[];

    return RouteDto(
      id: properties['id'] as String,
      name: properties['name'] as String,
      description: properties['description'] as String,
      distanceKm: (properties['distance_km'] as num).toDouble(),
      elevationGainM: elevationGain,
      difficulty: properties['difficulty'] as String,
      routeNumber: (properties['route_number'] as num).toInt(),
      coordinates: allCoordinates,
      stages: stages,
      cities: citiesList,
    );
  }

  /// Extract coordinates from geometry, handling both LineString and MultiLineString
  static List<List<double>> _extractCoordinates(Map<String, dynamic> geometry) {
    final geometryType = geometry['type'] as String;
    final rawCoords = geometry['coordinates'] as List<dynamic>;

    if (geometryType == 'MultiLineString') {
      // MultiLineString: coordinates is array of lines, each line is array of points
      // We need to flatten but keep segments separate (don't connect them)
      final result = <List<double>>[];
      for (final line in rawCoords) {
        final lineCoords = (line as List<dynamic>)
            .map(
              (coord) => (coord as List<dynamic>)
                  .map((c) => (c as num).toDouble())
                  .toList(),
            )
            .toList();
        result.addAll(lineCoords);
        // Add a null marker between segments to indicate a gap
        // We'll use an empty coordinate as a marker
        result.add(<double>[]);
      }
      // Remove the trailing marker
      if (result.isNotEmpty && result.last.isEmpty) {
        result.removeLast();
      }
      return result;
    }

    // LineString: coordinates is array of points
    return rawCoords
        .map(
          (coord) => (coord as List<dynamic>)
              .map((c) => (c as num).toDouble())
              .toList(),
        )
        .toList();
  }

  /// Check if two coordinates are the same (lng, lat match)
  static bool _coordinatesMatch(List<double> a, List<double> b) {
    if (a.length < 2 || b.length < 2) return false;
    return a[0] == b[0] && a[1] == b[1];
  }

  /// Check if two coordinates are close enough to be considered connected
  /// Uses a threshold of ~5km (about 0.05 degrees at mid-latitudes)
  /// Points further apart are considered a gap (e.g., ferry crossing)
  static bool _coordinatesAreClose(List<double> a, List<double> b) {
    if (a.length < 2 || b.length < 2) return false;
    const threshold = 0.05; // ~5km at mid-latitudes
    final dLng = (a[0] - b[0]).abs();
    final dLat = (a[1] - b[1]).abs();
    return dLng < threshold && dLat < threshold;
  }

  /// Calculate total elevation gain from coordinates with elevation (3rd value)
  static double _calculateElevationGain(List<List<double>> coordinates) {
    if (coordinates.isEmpty) return 0.0;

    double totalGain = 0.0;

    for (int i = 1; i < coordinates.length; i++) {
      // Check if coordinates have elevation data (3 values: lng, lat, elev)
      if (coordinates[i].length >= 3 && coordinates[i - 1].length >= 3) {
        final prevElevation = coordinates[i - 1][2];
        final currentElevation = coordinates[i][2];
        final elevationDiff = currentElevation - prevElevation;

        // Only count positive elevation changes (uphill)
        if (elevationDiff > 0) {
          totalGain += elevationDiff;
        }
      }
    }

    return totalGain;
  }

  /// Returns elevation as formatted string (e.g., "245 m")
  String get formattedElevation => '${elevationGainM.toStringAsFixed(0)} m';

  /// Returns distance as formatted string (e.g., "12.5 km")
  String get formattedDistance => '${distanceKm.toStringAsFixed(1)} km';

  /// Returns the center point of the route for initial map positioning
  List<double> get centerPoint {
    // Filter out empty coordinates (gap markers)
    final validCoords = coordinates.where((c) => c.length >= 2).toList();
    if (validCoords.isEmpty) return [0.0, 0.0];

    double sumLng = 0;
    double sumLat = 0;

    for (final coord in validCoords) {
      sumLng += coord[0];
      sumLat += coord[1];
    }

    return [sumLng / validCoords.length, sumLat / validCoords.length];
  }

  /// Returns bounding box [minLng, minLat, maxLng, maxLat]
  List<double> get boundingBox {
    // Filter out empty coordinates (gap markers)
    final validCoords = coordinates.where((c) => c.length >= 2).toList();
    if (validCoords.isEmpty) return [0, 0, 0, 0];

    double minLng = validCoords.first[0];
    double maxLng = validCoords.first[0];
    double minLat = validCoords.first[1];
    double maxLat = validCoords.first[1];

    for (final coord in validCoords) {
      if (coord[0] < minLng) minLng = coord[0];
      if (coord[0] > maxLng) maxLng = coord[0];
      if (coord[1] < minLat) minLat = coord[1];
      if (coord[1] > maxLat) maxLat = coord[1];
    }

    return [minLng, minLat, maxLng, maxLat];
  }

  RouteEntity toEntity() {
    const resolver = RouteColorResolver();
    return RouteEntity(
      id: id,
      name: name,
      description: description,
      distanceKm: distanceKm,
      elevationGainM: elevationGainM,
      difficulty: difficulty,
      routeNumber: routeNumber,
      colorValue: resolver.resolve(id: id, routeNumber: routeNumber),
      coordinates: coordinates,
      stages: stages.map((s) => s.toEntity()).toList(),
      cities: cities,
    );
  }
}
