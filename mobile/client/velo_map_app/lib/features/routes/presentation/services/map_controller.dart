import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:velo_map_app/features/routes/domain/entities/route_entity.dart';
import 'package:velo_map_app/features/routes/domain/entities/route_stage_entity.dart';
import 'package:velo_map_app/features/routes/domain/models/route_stage_status.dart';

/// Display modes for the map
enum MapDisplayMode {
  /// Show all routes on the map
  allRoutes,

  /// Show a single selected route
  singleRoute,

  /// Show a single stage of a route
  singleStage,

  /// Empty map - no routes displayed
  empty,
}

/// Manages map operations including route drawing, camera positioning, and location
class MapController {
  MapboxMap? _mapboxMap;
  PolylineAnnotationManager? _polylineManager;
  PointAnnotationManager? _pointManager;
  Cancelable? _polylineTapCancelable;
  bool _locationPermissionGranted = false;

  /// Operation ID to prevent race conditions when rapidly switching routes
  int _drawOperationId = 0;

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

  void setPointManager(PointAnnotationManager manager) {
    _pointManager = manager;
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

  /// Configure map settings (scale bar, disable native compass - using Flutter widget instead)
  Future<void> configureMapSettings() async {
    if (_mapboxMap == null) return;

    // Disable scale bar
    await _mapboxMap!.scaleBar.updateSettings(ScaleBarSettings(enabled: false));

    // Disable native compass - we use a Flutter widget instead for instant response
    await _mapboxMap!.compass.updateSettings(CompassSettings(enabled: false));
  }

  /// Reset map bearing to north (0 degrees)
  Future<void> resetBearing() async {
    if (_mapboxMap == null) return;

    final cameraState = await _mapboxMap!.getCameraState();
    await _mapboxMap!.flyTo(
      CameraOptions(
        center: cameraState.center,
        zoom: cameraState.zoom,
        bearing: 0,
        pitch: cameraState.pitch,
      ),
      MapAnimationOptions(duration: 300),
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

  // ============================================================================
  // UNIFIED MAP DISPLAY API
  // ============================================================================

  /// Clear all annotations from the map (polylines and point markers)
  Future<void> clearAllAnnotations() async {
    if (_polylineManager != null) {
      await _polylineManager!.deleteAll();
    }
    if (_pointManager != null) {
      await _pointManager!.deleteAll();
    }
  }

  /// Unified method to update map display based on current state.
  /// Handles race conditions by cancelling stale operations.
  ///
  /// - [mode]: What to display on the map
  /// - [allRoutes]: Required for [MapDisplayMode.allRoutes]
  /// - [selectedRoute]: Required for [MapDisplayMode.singleRoute] and [MapDisplayMode.singleStage]
  /// - [selectedStage]: Required for [MapDisplayMode.singleStage]
  /// - [fitCamera]: Whether to animate camera to fit content (default: true)
  Future<void> updateMapDisplay({
    required MapDisplayMode mode,
    List<RouteEntity>? allRoutes,
    RouteEntity? selectedRoute,
    RouteStageEntity? selectedStage,
    bool fitCamera = true,
  }) async {
    if (_mapboxMap == null || _polylineManager == null) return;

    // Increment operation ID - any previous operation becomes stale
    final operationId = ++_drawOperationId;

    // Step 1: Always clear everything first
    await clearAllAnnotations();

    // Check if this operation is still valid
    if (operationId != _drawOperationId) return;

    // Step 2: Draw based on mode
    switch (mode) {
      case MapDisplayMode.allRoutes:
        if (allRoutes == null || allRoutes.isEmpty) return;
        await _drawAllRoutes(allRoutes, operationId);
        if (operationId != _drawOperationId) return;
        if (fitCamera) {
          await fitCameraToRoutes(allRoutes);
        }

      case MapDisplayMode.singleRoute:
        if (selectedRoute == null) return;
        final lineColor = Color(selectedRoute.colorValue).toARGB32();
        await _drawSingleRoute(selectedRoute, lineColor, operationId);
        if (operationId != _drawOperationId) return;
        if (fitCamera) {
          await fitCameraToBounds(selectedRoute.boundingBox);
        }

      case MapDisplayMode.singleStage:
        if (selectedRoute == null || selectedStage == null) return;
        final lineColor = Color(selectedRoute.colorValue).toARGB32();
        await _drawSingleStage(
          selectedStage,
          lineColor,
          selectedRoute.id,
          operationId,
        );
        if (operationId != _drawOperationId) return;
        if (fitCamera) {
          await _fitCameraToStageBounds(selectedStage);
        }

      case MapDisplayMode.empty:
        // Already cleared, optionally return to user location
        if (fitCamera) {
          await _returnToDefaultLocation();
        }
    }
  }

  // ============================================================================
  // PRIVATE DRAWING METHODS
  // ============================================================================

  /// Draw all routes on the map
  Future<void> _drawAllRoutes(List<RouteEntity> routes, int operationId) async {
    for (final route in routes) {
      if (route.stages.isEmpty) continue;

      for (final stage in route.stages) {
        if (stage.coordinates.isEmpty) continue;

        // Check if operation is still valid before each draw
        if (operationId != _drawOperationId) return;

        final positions = stage.coordinates
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
  }

  /// Draw a single route on the map
  Future<void> _drawSingleRoute(
    RouteEntity route,
    int lineColor,
    int operationId,
  ) async {
    if (route.stages.isEmpty) return;

    for (final stage in route.stages) {
      if (stage.coordinates.isEmpty) continue;

      // Check if operation is still valid
      if (operationId != _drawOperationId) return;

      final positions = stage.coordinates
          .map((coord) => Position(coord[0], coord[1]))
          .toList();

      final polylineOptions = PolylineAnnotationOptions(
        geometry: LineString(coordinates: positions),
        lineColor: lineColor,
        lineWidth: 5.0,
        lineOpacity: 0.9,
        customData: {'routeId': route.id},
      );

      await _polylineManager!.create(polylineOptions);
    }
  }

  /// Draw a single stage on the map with status markers
  Future<void> _drawSingleStage(
    RouteStageEntity stage,
    int lineColor,
    String routeId,
    int operationId,
  ) async {
    if (stage.coordinates.isEmpty) return;

    // Check if operation is still valid
    if (operationId != _drawOperationId) return;

    final positions = stage.coordinates
        .map((coord) => Position(coord[0], coord[1]))
        .toList();

    // Draw polyline with slightly thicker line for emphasis
    final polylineOptions = PolylineAnnotationOptions(
      geometry: LineString(coordinates: positions),
      lineColor: lineColor,
      lineWidth: 6.0,
      lineOpacity: 1.0,
      customData: {'routeId': routeId},
    );

    await _polylineManager!.create(polylineOptions);

    // Check again before adding markers
    if (operationId != _drawOperationId) return;

    // Add status markers along the stage
    await _showStageStatusMarkers(stage, operationId);
  }

  /// Show status markers along the stage route
  Future<void> _showStageStatusMarkers(
    RouteStageEntity stage,
    int operationId,
  ) async {
    if (_pointManager == null || stage.coordinates.isEmpty) return;

    // Generate status icon image
    final status = stage.status;
    final iconBytes = await _generateStatusIconImage(status);

    if (iconBytes == null) return;
    if (operationId != _drawOperationId) return;

    // Get positions for markers: start, 1/3, 2/3, and end of route
    final coords = stage.coordinates;
    final markerIndices = _getMarkerIndices(coords.length);

    for (final index in markerIndices) {
      if (operationId != _drawOperationId) return;

      final coord = coords[index];
      final position = Position(coord[0], coord[1]);

      // Create point annotation with status icon
      final pointOptions = PointAnnotationOptions(
        geometry: Point(coordinates: position),
        image: iconBytes,
        iconSize: 1.0,
        iconAnchor: IconAnchor.CENTER,
      );

      await _pointManager!.create(pointOptions);
    }
  }

  /// Get indices for placing markers along the route
  /// Places markers at start, ~1/3, ~2/3, and end positions
  List<int> _getMarkerIndices(int totalCoords) {
    if (totalCoords <= 0) return [];
    if (totalCoords == 1) return [0];
    if (totalCoords <= 3) return [0, totalCoords - 1];
    if (totalCoords <= 6) return [0, totalCoords ~/ 2, totalCoords - 1];

    // For longer routes, place 4 markers
    return [
      0, // Start
      totalCoords ~/ 3, // 1/3 of the way
      (totalCoords * 2) ~/ 3, // 2/3 of the way
      totalCoords - 1, // End
    ];
  }

  /// Generate a status icon image as bytes
  Future<Uint8List?> _generateStatusIconImage(RouteStageStatus status) async {
    // Larger size for better visibility on map
    const size = 80.0;
    const padding = 12.0;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Draw background circle
    final bgPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    // Draw shadow
    canvas.drawCircle(
      const Offset(size / 2, size / 2 + 3),
      size / 2 - padding,
      shadowPaint,
    );

    // Draw white background
    canvas.drawCircle(
      const Offset(size / 2, size / 2),
      size / 2 - padding,
      bgPaint,
    );

    // Draw colored border
    final borderPaint = Paint()
      ..color = status.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawCircle(
      const Offset(size / 2, size / 2),
      size / 2 - padding,
      borderPaint,
    );

    // Draw status icon using a text painter with material icons font
    final iconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(status.icon.codePoint),
        style: TextStyle(
          fontSize: 36,
          fontFamily: status.icon.fontFamily,
          package: status.icon.fontPackage,
          color: status.color,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    iconPainter.layout();
    iconPainter.paint(
      canvas,
      Offset((size - iconPainter.width) / 2, (size - iconPainter.height) / 2),
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    return byteData?.buffer.asUint8List();
  }

  // ============================================================================
  // CAMERA METHODS
  // ============================================================================

  /// Return to user's location or default position
  Future<void> _returnToDefaultLocation() async {
    if (_mapboxMap == null) return;

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
  Future<void> _fitCameraToStageBounds(RouteStageEntity stage) async {
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
    _pointManager = null;
    _polylineTapCancelable?.cancel();
    _polylineTapCancelable = null;
    _drawOperationId = 0;
  }
}
