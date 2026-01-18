import 'package:geolocator/geolocator.dart' as geo;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:velo_map_app/features/routes/domain/entities/route_entity.dart';
import 'package:velo_map_app/features/routes/domain/entities/route_stage_entity.dart';

/// Manages map operations including route drawing, camera positioning, and location
class MapController {
  MapboxMap? _mapboxMap;
  PolylineAnnotationManager? _polylineManager;
  Cancelable? _polylineTapCancelable;
  bool _locationPermissionGranted = false;

  // Default camera position (Tel Aviv area)
  static final defaultCenter = Point(coordinates: Position(34.78, 32.08));
  static const defaultZoom = 11.0;

  MapboxMap? get mapboxMap => _mapboxMap;
  bool get locationPermissionGranted => _locationPermissionGranted;

  void setMapboxMap(MapboxMap map) {
    _mapboxMap = map;
  }

  void setPolylineManager(PolylineAnnotationManager manager) {
    _polylineManager = manager;
  }

  void setRouteTapHandler(void Function(String routeId) onRouteTap) {
    if (_polylineManager == null) return;
    _polylineTapCancelable?.cancel();
    _polylineTapCancelable = _polylineManager!.tapEvents(
      onTap: (annotation) {
        final data = annotation.customData;
        final routeId = data?['routeId'];
        if (routeId is String && routeId.isNotEmpty) {
          onRouteTap(routeId);
        }
      },
    );
  }

  void setLocationPermissionGranted(bool granted) {
    _locationPermissionGranted = granted;
  }

  /// Configure map settings (scale bar, compass positioning)
  Future<void> configureMapSettings({
    required double screenHeight,
    required double bottomSheetMidHeight,
  }) async {
    if (_mapboxMap == null) return;

    // Disable scale bar
    await _mapboxMap!.scaleBar.updateSettings(ScaleBarSettings(enabled: false));

    // Configure compass - position it above location button
    await updateCompassPosition(
      screenHeight: screenHeight,
      bottomSheetHeight: bottomSheetMidHeight,
    );
  }

  /// Update compass position based on bottom sheet height
  Future<void> updateCompassPosition({
    required double screenHeight,
    required double bottomSheetHeight,
    bool hidden = false,
  }) async {
    if (_mapboxMap == null) return;

    // Hide compass when sheet is maximized
    if (hidden) {
      await _mapboxMap!.compass.updateSettings(
        CompassSettings(enabled: false),
      );
      return;
    }

    // Location button is at: (screenHeight * bottomSheetHeight + 16) from bottom
    // Location button height: 40px (FloatingActionButton.small)
    // Compass should be 10px above the location button
    final locationButtonBottom = screenHeight * bottomSheetHeight + 16;
    final compassBottom = locationButtonBottom + 40 + 10;

    await _mapboxMap!.compass.updateSettings(
      CompassSettings(
        enabled: true,
        position: OrnamentPosition.BOTTOM_RIGHT,
        marginBottom: compassBottom,
        marginRight: 16,
      ),
    );
  }

  /// Move camera to current location if available (no animation, used at startup)
  Future<void> moveToCurrentLocation() async {
    if (_mapboxMap == null) return;

    try {
      final position = await geo.Geolocator.getCurrentPosition(
        locationSettings: geo.LocationSettings(
          accuracy: geo.LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 5),
        ),
      );
      await _mapboxMap!.setCamera(
        CameraOptions(
          center: Point(
            coordinates: Position(position.longitude, position.latitude),
          ),
          zoom: defaultZoom,
        ),
      );
    } catch (_) {
      // Location unavailable - keep default Tel Aviv position
    }
  }

  /// Animate camera to user's current location
  Future<void> goToUserLocation() async {
    if (_mapboxMap == null || !_locationPermissionGranted) return;

    try {
      // Get current position using Geolocator
      final position = await geo.Geolocator.getCurrentPosition();

      await _mapboxMap!.flyTo(
        CameraOptions(
          center: Point(
            coordinates: Position(position.longitude, position.latitude),
          ),
          zoom: 15.0,
        ),
        MapAnimationOptions(duration: 800),
      );
    } catch (e) {
      // If getting current position fails, try last known position
      final lastPosition = await geo.Geolocator.getLastKnownPosition();
      if (lastPosition != null && _mapboxMap != null) {
        await _mapboxMap!.flyTo(
          CameraOptions(
            center: Point(
              coordinates: Position(
                lastPosition.longitude,
                lastPosition.latitude,
              ),
            ),
            zoom: 15.0,
          ),
          MapAnimationOptions(duration: 800),
        );
      }
    }
  }

  /// Draw a full route on the map
  Future<void> drawRoute(RouteEntity route, int lineColor) async {
    if (_polylineManager == null || _mapboxMap == null) return;

    // Clear existing annotations
    await _polylineManager!.deleteAll();

    // Convert coordinates to Position list
    final positions = route.coordinates
        .map((coord) => Position(coord[0], coord[1]))
        .toList();

    // Create polyline annotation
    final polylineOptions = PolylineAnnotationOptions(
      geometry: LineString(coordinates: positions),
      lineColor: lineColor,
      lineWidth: 5.0,
      lineOpacity: 0.9,
      customData: {'routeId': route.id},
    );

    await _polylineManager!.create(polylineOptions);

    // Fit camera to route bounds
    await fitCameraToBounds(route.boundingBox);
  }

  /// Draw all routes on the map
  Future<void> drawRoutes(List<RouteEntity> routes) async {
    if (_polylineManager == null || _mapboxMap == null) return;

    await _polylineManager!.deleteAll();

    for (final route in routes) {
      if (route.coordinates.isEmpty) continue;

      final positions = route.coordinates
          .map((coord) => Position(coord[0], coord[1]))
          .toList();

      final polylineOptions = PolylineAnnotationOptions(
        geometry: LineString(coordinates: positions),
        lineColor: route.colorValue,
        lineWidth: 5.0,
        lineOpacity: 0.9,
        customData: {'routeId': route.id},
      );

      await _polylineManager!.create(polylineOptions);
    }
  }

  /// Draw a route stage on the map
  Future<void> drawStage(
    RouteStageEntity stage,
    int lineColor, {
    String? routeId,
  }) async {
    if (_polylineManager == null || _mapboxMap == null) return;

    // Clear existing annotations
    await _polylineManager!.deleteAll();

    // Convert coordinates to Position list
    final positions = stage.coordinates
        .map((coord) => Position(coord[0], coord[1]))
        .toList();

    // Create polyline annotation with different style for stage
    final polylineOptions = PolylineAnnotationOptions(
      geometry: LineString(coordinates: positions),
      lineColor: lineColor,
      lineWidth: 6.0,
      lineOpacity: 1.0,
      customData: routeId != null ? {'routeId': routeId} : null,
    );

    await _polylineManager!.create(polylineOptions);

    // Fit camera to stage bounds
    await fitCameraToStageBounds(stage);
  }

  /// Clear route from map and return to user location or default
  Future<void> clearRoute() async {
    if (_polylineManager == null) return;
    await _polylineManager!.deleteAll();

    // Return to user's location, or default if unavailable
    if (_mapboxMap != null) {
      if (_locationPermissionGranted) {
        try {
          // First try last known position (instant, no waiting)
          final lastPosition = await geo.Geolocator.getLastKnownPosition();
          if (lastPosition != null) {
            await _mapboxMap!.flyTo(
              CameraOptions(
                center: Point(
                  coordinates: Position(
                    lastPosition.longitude,
                    lastPosition.latitude,
                  ),
                ),
                zoom: defaultZoom,
              ),
              MapAnimationOptions(duration: 500),
            );
            return;
          }

          // If no last known, try current position with short timeout
          final position = await geo.Geolocator.getCurrentPosition(
            locationSettings: geo.LocationSettings(
              accuracy: geo.LocationAccuracy.low,
              timeLimit: const Duration(seconds: 2),
            ),
          );
          await _mapboxMap!.flyTo(
            CameraOptions(
              center: Point(
                coordinates: Position(position.longitude, position.latitude),
              ),
              zoom: defaultZoom,
            ),
            MapAnimationOptions(duration: 500),
          );
          return;
        } catch (_) {
          // Fall through to default location
        }
      }

      // Fallback to default location if current location unavailable
      await _mapboxMap!.flyTo(
        CameraOptions(center: defaultCenter, zoom: defaultZoom),
        MapAnimationOptions(duration: 500),
      );
    }
  }

  /// Fit camera to route bounding box
  Future<void> fitCameraToBounds(List<double> bbox) async {
    if (_mapboxMap == null) return;

    const padding = 10.0;

    final cameraOptions = await _mapboxMap!.cameraForCoordinateBounds(
      CoordinateBounds(
        southwest: Point(coordinates: Position(bbox[0], bbox[1])),
        northeast: Point(coordinates: Position(bbox[2], bbox[3])),
        infiniteBounds: false,
      ),
      MbxEdgeInsets(
        top: padding,
        left: padding,
        bottom: padding + 200,
        right: padding,
      ),
      null,
      null,
      null,
      null,
    );

    await _mapboxMap!.flyTo(cameraOptions, MapAnimationOptions(duration: 800));
  }

  /// Fit camera to stage bounding box
  Future<void> fitCameraToStageBounds(RouteStageEntity stage) async {
    if (_mapboxMap == null || stage.coordinates.isEmpty) return;

    // Calculate bounding box for stage
    double minLng = stage.coordinates.first[0];
    double maxLng = stage.coordinates.first[0];
    double minLat = stage.coordinates.first[1];
    double maxLat = stage.coordinates.first[1];

    for (final coord in stage.coordinates) {
      if (coord[0] < minLng) minLng = coord[0];
      if (coord[0] > maxLng) maxLng = coord[0];
      if (coord[1] < minLat) minLat = coord[1];
      if (coord[1] > maxLat) maxLat = coord[1];
    }

    const padding = 80.0;

    final cameraOptions = await _mapboxMap!.cameraForCoordinateBounds(
      CoordinateBounds(
        southwest: Point(coordinates: Position(minLng, minLat)),
        northeast: Point(coordinates: Position(maxLng, maxLat)),
        infiniteBounds: false,
      ),
      MbxEdgeInsets(
        top: padding,
        left: padding,
        bottom: padding + 200,
        right: padding,
      ),
      null,
      null,
      null,
      null,
    );

    await _mapboxMap!.flyTo(cameraOptions, MapAnimationOptions(duration: 800));
  }

  /// Fit camera to bounds that include all routes
  Future<void> fitCameraToRoutes(List<RouteEntity> routes) async {
    final bounds = _routesBounds(routes);
    if (bounds == null) return;
    await fitCameraToBounds(bounds);
  }

  List<double>? _routesBounds(List<RouteEntity> routes) {
    double? minLng;
    double? maxLng;
    double? minLat;
    double? maxLat;

    for (final route in routes) {
      if (route.coordinates.isEmpty) continue;
      final bbox = route.boundingBox;

      minLng = minLng == null ? bbox[0] : (bbox[0] < minLng ? bbox[0] : minLng);
      minLat = minLat == null ? bbox[1] : (bbox[1] < minLat ? bbox[1] : minLat);
      maxLng = maxLng == null ? bbox[2] : (bbox[2] > maxLng ? bbox[2] : maxLng);
      maxLat = maxLat == null ? bbox[3] : (bbox[3] > maxLat ? bbox[3] : maxLat);
    }

    if (minLng == null || minLat == null || maxLng == null || maxLat == null) {
      return null;
    }

    return [minLng, minLat, maxLng, maxLat];
  }

  void dispose() {
    _mapboxMap = null;
    _polylineManager = null;
    _polylineTapCancelable?.cancel();
    _polylineTapCancelable = null;
  }
}
