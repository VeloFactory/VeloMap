import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart' hide Position;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:velo_map_app/features/routes/domain/entities/route_entity.dart';
import 'package:velo_map_app/features/routes/domain/entities/route_stage_entity.dart';
import 'package:velo_map_app/features/routes/presentation/bloc/routes_bloc.dart';
import 'package:velo_map_app/features/routes/presentation/bloc/routes_event.dart';
import 'package:velo_map_app/features/routes/presentation/bloc/routes_state.dart';
import 'package:velo_map_app/features/routes/presentation/widgets/route_list_tile.dart';

class Routes extends StatefulWidget {
  const Routes({super.key});

  @override
  State<Routes> createState() => _RoutesState();
}

class _RoutesState extends State<Routes> {
  final DraggableScrollableController _sheet = DraggableScrollableController();
  MapboxMap? _mapboxMap;
  PolylineAnnotationManager? _polylineManager;
  bool _locationPermissionGranted = false;

  static const double _min = 0.108;
  static const double _mid = 0.40;
  static const double _max = 0.96;

  final snapSizes = <double>[_min, _mid, _max];

  // Default camera position (Tel Aviv area)
  static final _defaultCenter = Point(coordinates: Position(34.78, 32.08));
  static const _defaultZoom = 11.0;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  @override
  void dispose() {
    _sheet.dispose();
    super.dispose();
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.locationWhenInUse.request();
    setState(() {
      _locationPermissionGranted = status.isGranted;
    });

    if (status.isGranted && _mapboxMap != null) {
      await _enableUserLocation();
    }
  }

  Future<void> _enableUserLocation() async {
    if (_mapboxMap == null || !_locationPermissionGranted) return;

    // Enable the location component with puck
    final locationSettings = _mapboxMap!.location;
    await locationSettings.updateSettings(
      LocationComponentSettings(
        enabled: true,
        pulsingEnabled: true,
        pulsingColor: Theme.of(context).colorScheme.primary.toARGB32(),
        showAccuracyRing: true,
        puckBearingEnabled: true,
      ),
    );
  }

  void _onMapCreated(MapboxMap mapboxMap) async {
    _mapboxMap = mapboxMap;

    // Disable scale bar
    await mapboxMap.scaleBar.updateSettings(ScaleBarSettings(enabled: false));

    // Create polyline annotation manager for drawing routes
    _polylineManager = await mapboxMap.annotations
        .createPolylineAnnotationManager();

    // Enable user location if permission already granted
    if (_locationPermissionGranted) {
      await _enableUserLocation();
    }
  }

  Future<void> _drawRoute(RouteEntity route) async {
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
      lineColor: Colors.blue.toARGB32(),
      lineWidth: 5.0,
      lineOpacity: 0.9,
    );

    await _polylineManager!.create(polylineOptions);

    // Fit camera to route bounds
    await _fitCameraToBounds(route);
  }

  Future<void> _drawStage(RouteStageEntity stage) async {
    if (_polylineManager == null || _mapboxMap == null) return;

    // Clear existing annotations
    await _polylineManager!.deleteAll();

    // Convert coordinates to Position list
    final positions = stage.coordinates
        .map((coord) => Position(coord[0], coord[1]))
        .toList();

    // Create polyline annotation with different color for stage
    final polylineOptions = PolylineAnnotationOptions(
      geometry: LineString(coordinates: positions),
      lineColor: Colors.blue.toARGB32(),
      lineWidth: 6.0,
      lineOpacity: 1.0,
    );

    await _polylineManager!.create(polylineOptions);

    // Fit camera to stage bounds
    await _fitCameraToStageBounds(stage);
  }

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

    final padding = 80.0;

    // Create camera bounds
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

  Future<void> _fitCameraToBounds(RouteEntity route) async {
    if (_mapboxMap == null) return;

    final bbox = route.boundingBox;
    final padding = 80.0;

    // Create camera bounds
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

  Future<void> _clearRoute() async {
    if (_polylineManager == null) return;
    await _polylineManager!.deleteAll();

    // Reset camera to default
    if (_mapboxMap != null) {
      await _mapboxMap!.flyTo(
        CameraOptions(center: _defaultCenter, zoom: _defaultZoom),
        MapAnimationOptions(duration: 500),
      );
    }
  }

  Future<void> _goToUserLocation() async {
    if (_mapboxMap == null || !_locationPermissionGranted) {
      // Request permission if not granted
      await _requestLocationPermission();
      return;
    }

    try {
      // Get current position using Geolocator
      final position = await Geolocator.getCurrentPosition();

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
      final lastPosition = await Geolocator.getLastKnownPosition();
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocConsumer<RoutesBloc, RoutesState>(
      listener: (context, state) {
        if (state.selectedRoute != null) {
          // If a stage is selected, draw only that stage; otherwise draw full route
          if (state.selectedStage != null) {
            _drawStage(state.selectedStage!);
          } else {
            _drawRoute(state.selectedRoute!);
          }
          // Expand sheet to show route details
          if (_sheet.isAttached) {
            _sheet.animateTo(
              _max,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
            );
          }
        } else {
          _clearRoute();
          // Collapse sheet when no route selected
          if (_sheet.isAttached) {
            _sheet.animateTo(
              _mid,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
            );
          }
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: Stack(
            children: [
              // Map
              MapWidget(
                key: const ValueKey("mapWidget"),
                onMapCreated: _onMapCreated,
                cameraOptions: CameraOptions(
                  center: _defaultCenter,
                  zoom: _defaultZoom,
                ),
              ),

              // Map controls (Location + Zoom)
              Positioned(
                left: 16,
                top: MediaQuery.of(context).padding.top + 16,
                child: Column(
                  children: [
                    // Location FAB
                    FloatingActionButton.small(
                      heroTag: 'location_fab',
                      onPressed: _goToUserLocation,
                      backgroundColor: colorScheme.surface,
                      foregroundColor: _locationPermissionGranted
                          ? colorScheme.primary
                          : colorScheme.outline,
                      elevation: 2,
                      child: Icon(
                        _locationPermissionGranted
                            ? Icons.my_location_rounded
                            : Icons.location_disabled_rounded,
                      ),
                    ),
                  ],
                ),
              ),

              // Loading indicator
              if (state.isLoading)
                const Center(child: CircularProgressIndicator()),

              // Bottom sheet with routes list
              DraggableScrollableSheet(
                controller: _sheet,
                initialChildSize: _min,
                minChildSize: _min,
                maxChildSize: _max,
                snap: true,
                snapSizes: snapSizes,
                builder: (context, scrollController) {
                  return _buildBottomSheet(
                    context,
                    scrollController,
                    state,
                    colorScheme,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomSheet(
    BuildContext context,
    ScrollController scrollController,
    RoutesState state,
    ColorScheme colorScheme,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            spreadRadius: 5,
            offset: const Offset(0, -4),
            color: colorScheme.shadow.withValues(alpha: 0.15),
          ),
        ],
      ),
      child: Column(
        children: [
          // Handle + Header
          _buildSheetHeader(context, state, colorScheme),
          // Content
          Expanded(
            child: state.error != null
                ? _buildErrorView(state.error!, colorScheme)
                : state.routes.isEmpty && !state.isLoading
                ? _buildEmptyView(colorScheme)
                : _buildRoutesList(scrollController, state),
          ),
        ],
      ),
    );
  }

  Widget _buildSheetHeader(
    BuildContext context,
    RoutesState state,
    ColorScheme colorScheme,
  ) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragUpdate: (details) {
        if (!_sheet.isAttached) return;
        final screenH = MediaQuery.of(context).size.height;
        final delta = -details.delta.dy / screenH;
        final next = (_sheet.size + delta).clamp(_min, _max).toDouble();
        _sheet.jumpTo(next);
      },
      onVerticalDragEnd: (_) {
        if (!_sheet.isAttached) return;
        final current = _sheet.size;
        double nearest = snapSizes.first;
        double bestDist = (current - nearest).abs();
        for (final s in snapSizes.skip(1)) {
          final d = (current - s).abs();
          if (d < bestDist) {
            bestDist = d;
            nearest = s;
          }
        }
        _sheet.animateTo(
          nearest,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      },
      child: Column(
        children: [
          const SizedBox(height: 12),
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.outline.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          // Title row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(Icons.route_rounded, color: colorScheme.primary, size: 24),
                const SizedBox(width: 10),
                Text(
                  'EuroVelo Routes',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                if (state.selectedRoute != null)
                  TextButton.icon(
                    onPressed: () {
                      context.read<RoutesBloc>().add(
                        const RoutesEvent.clearSelection(),
                      );
                    },
                    icon: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: colorScheme.primary,
                    ),
                    label: Text(
                      'Clear',
                      style: TextStyle(color: colorScheme.primary),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildRoutesList(
    ScrollController scrollController,
    RoutesState state,
  ) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      itemCount: state.routes.length,
      itemBuilder: (context, index) {
        final route = state.routes[index];
        final isSelected = state.selectedRoute?.id == route.id;

        return RouteListTile(
          route: route,
          isSelected: isSelected,
          selectedStage: isSelected ? state.selectedStage : null,
          onTap: () {
            if (isSelected) {
              context.read<RoutesBloc>().add(
                const RoutesEvent.clearSelection(),
              );
            } else {
              context.read<RoutesBloc>().add(RoutesEvent.selectRoute(route));
            }
          },
          onStageSelected: (stage) {
            context.read<RoutesBloc>().add(RoutesEvent.selectStage(stage));
          },
          onStageClear: () {
            context.read<RoutesBloc>().add(
              const RoutesEvent.clearStageSelection(),
            );
          },
        );
      },
    );
  }

  Widget _buildErrorView(String error, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load routes',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            // const SizedBox(height: 8),
            // Text(
            //   error,
            //   style: TextStyle(
            //     fontSize: 14,
            //     color: colorScheme.onSurfaceVariant,
            //   ),
            //   textAlign: TextAlign.center,
            // ),
            // const SizedBox(height: 24),
            // FilledButton.icon(
            //   onPressed: () {
            //     context.read<RoutesBloc>().add(const RoutesEvent.load());
            //   },
            //   icon: const Icon(Icons.refresh_rounded),
            //   label: const Text('Retry'),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView(ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.map_outlined, size: 48, color: colorScheme.outline),
            const SizedBox(height: 16),
            Text(
              'No routes available',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Routes will appear here once loaded',
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
