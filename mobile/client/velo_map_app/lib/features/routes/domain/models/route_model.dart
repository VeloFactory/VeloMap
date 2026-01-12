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
    required double elevationGainM,
    required String difficulty,
    required int routeNumber,
    required List<List<double>> coordinates,
  }) = _RouteModel;

  factory RouteModel.fromJson(Map<String, dynamic> json) =>
      _$RouteModelFromJson(json);

  /// Factory to parse a GeoJSON Feature or FeatureCollection into RouteModel
  factory RouteModel.fromGeoJson(Map<String, dynamic> geoJson) {
    final type = geoJson['type'] as String;

    // Handle FeatureCollection (multi-stage routes)
    if (type == 'FeatureCollection') {
      return _fromFeatureCollection(geoJson);
    }

    // Handle single Feature (simple routes)
    return _fromSingleFeature(geoJson);
  }

  /// Parse a single Feature GeoJSON
  static RouteModel _fromSingleFeature(Map<String, dynamic> geoJson) {
    final properties = geoJson['properties'] as Map<String, dynamic>;
    final geometry = geoJson['geometry'] as Map<String, dynamic>;
    final rawCoords = geometry['coordinates'] as List<dynamic>;

    final coordinates = rawCoords
        .map((coord) => (coord as List<dynamic>)
            .map((c) => (c as num).toDouble())
            .toList())
        .toList();

    // Calculate elevation gain from coordinates (if elevation data exists)
    final elevationGain = _calculateElevationGain(coordinates);

    return RouteModel(
      id: properties['id'] as String,
      name: properties['name'] as String,
      description: properties['description'] as String,
      distanceKm: (properties['distance_km'] as num).toDouble(),
      elevationGainM: elevationGain,
      difficulty: properties['difficulty'] as String,
      routeNumber: (properties['route_number'] as num).toInt(),
      coordinates: coordinates,
    );
  }

  /// Parse a FeatureCollection GeoJSON (multi-stage routes)
  static RouteModel _fromFeatureCollection(Map<String, dynamic> geoJson) {
    final properties = geoJson['properties'] as Map<String, dynamic>;
    final features = geoJson['features'] as List<dynamic>;

    // Merge coordinates from all features, avoiding duplicates at stage boundaries
    final allCoordinates = <List<double>>[];
    
    for (int i = 0; i < features.length; i++) {
      final feature = features[i] as Map<String, dynamic>;
      final geometry = feature['geometry'] as Map<String, dynamic>;
      final rawCoords = geometry['coordinates'] as List<dynamic>;

      final stageCoords = rawCoords
          .map((coord) => (coord as List<dynamic>)
              .map((c) => (c as num).toDouble())
              .toList())
          .toList();

      // Skip first coordinate if it matches the last one from previous stage
      final startIndex = (i > 0 && 
          allCoordinates.isNotEmpty && 
          _coordinatesMatch(allCoordinates.last, stageCoords.first)) ? 1 : 0;
      
      allCoordinates.addAll(stageCoords.sublist(startIndex));
    }

    // Calculate elevation gain from merged coordinates
    final elevationGain = _calculateElevationGain(allCoordinates);

    return RouteModel(
      id: properties['id'] as String,
      name: properties['name'] as String,
      description: properties['description'] as String,
      distanceKm: (properties['distance_km'] as num).toDouble(),
      elevationGainM: elevationGain,
      difficulty: properties['difficulty'] as String,
      routeNumber: (properties['route_number'] as num).toInt(),
      coordinates: allCoordinates,
    );
  }

  /// Check if two coordinates are the same (lng, lat match)
  static bool _coordinatesMatch(List<double> a, List<double> b) {
    if (a.length < 2 || b.length < 2) return false;
    return a[0] == b[0] && a[1] == b[1];
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
