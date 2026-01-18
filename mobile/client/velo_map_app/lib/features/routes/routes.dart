import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:velo_map_app/features/routes/domain/entities/route_entity.dart';
import 'package:velo_map_app/features/routes/presentation/bloc/routes_bloc.dart';
import 'package:velo_map_app/features/routes/presentation/bloc/routes_event.dart';
import 'package:velo_map_app/features/routes/presentation/bloc/routes_state.dart';
import 'package:velo_map_app/features/routes/presentation/services/map_controller.dart';
import 'package:velo_map_app/features/routes/presentation/widgets/routes_bottom_sheet.dart';
import 'package:velo_map_app/features/routes/presentation/widgets/routes_search_bar.dart';

class Routes extends StatefulWidget {
  const Routes({super.key});

  @override
  State<Routes> createState() => _RoutesState();
}

class _RoutesState extends State<Routes> {
  final DraggableScrollableController _sheet = DraggableScrollableController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final MapController _mapController = MapController();
  bool _isSearchVisible = false;
  List<RouteEntity>? _lastRoutes;
  double _currentSheetSize = _min;
  double _mapBearing = 0.0;

  static const double _min = 0.108;
  static const double _mid = 0.40;
  static const double _max = 0.96;

  final snapSizes = <double>[_min, _mid, _max];

  @override
  void initState() {
    super.initState();
    _sheet.addListener(_onSheetPositionChanged);
    _requestLocationPermission();
  }

  void _onSheetPositionChanged() {
    if (!_sheet.isAttached) return;
    final newSize = _sheet.size;
    if (newSize != _currentSheetSize) {
      setState(() {
        _currentSheetSize = newSize;
      });
    }
  }

  @override
  void dispose() {
    _sheet.removeListener(_onSheetPositionChanged);
    _sheet.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
      if (_isSearchVisible) {
        _searchFocusNode.requestFocus();
      } else {
        _searchController.clear();
        _searchFocusNode.unfocus();
        context.read<RoutesBloc>().add(const RoutesEvent.clearSearch());
      }
    });
  }

  void _onSearchChanged(String query) {
    context.read<RoutesBloc>().add(RoutesEvent.search(query));
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.locationWhenInUse.request();
    _mapController.setLocationPermissionGranted(status.isGranted);
    setState(() {});

    if (status.isGranted && _mapController.mapboxMap != null) {
      await _enableUserLocation();
    }
  }

  Future<void> _enableUserLocation() async {
    if (_mapController.mapboxMap == null ||
        !_mapController.locationPermissionGranted) {
      return;
    }

    // Enable the location component with puck
    final locationSettings = _mapController.mapboxMap!.location;
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
    _mapController.setMapboxMap(mapboxMap);

    // Configure map settings (disable native compass, we use Flutter widget instead)
    await _mapController.configureMapSettings();

    // Create polyline annotation manager for drawing routes
    final polylineManager = await mapboxMap.annotations
        .createPolylineAnnotationManager();
    _mapController.setPolylineManager(polylineManager);
    _mapController.setRouteTapHandler(_showRouteId);

    if (!mounted) return;
    final routes = context.read<RoutesBloc>().state.routes;
    final hasRoutes = routes.isNotEmpty;
    if (hasRoutes) {
      await _mapController.drawRoutes(routes);
      await _mapController.fitCameraToRoutes(routes);
      _lastRoutes = routes;
    }

    // Enable user location if permission already granted
    if (_mapController.locationPermissionGranted) {
      await _enableUserLocation();
      if (!hasRoutes) {
        await _mapController.moveToCurrentLocation();
      }
    }
  }

  void _showRouteId(String routeId) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Route ID: $routeId')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocConsumer<RoutesBloc, RoutesState>(
      listenWhen: (previous, current) =>
          previous.routes != current.routes ||
          previous.selectedRoute != current.selectedRoute ||
          previous.selectedStage != current.selectedStage,
      listener: (context, state) {
        final selectedRoute = state.selectedRoute;

        if (selectedRoute != null) {
          final lineColor = Color(selectedRoute.colorValue).toARGB32();
          // If a stage is selected, draw only that stage; otherwise draw full route
          if (state.selectedStage != null) {
            _mapController.drawStage(
              state.selectedStage!,
              lineColor,
              routeId: selectedRoute.id,
            );
          } else {
            _mapController.drawRoute(selectedRoute, lineColor);
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
          if (state.routes.isNotEmpty) {
            _mapController.drawRoutes(state.routes);
            if (_lastRoutes != state.routes) {
              _mapController.fitCameraToRoutes(state.routes);
              _lastRoutes = state.routes;
            }
          } else {
            _mapController.clearRoute();
          }
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
          // Prevent keyboard from pushing UI up when search is active
          resizeToAvoidBottomInset: !_isSearchVisible,
          body: Stack(
            children: [
              // Map
              MapWidget(
                key: const ValueKey("mapWidget"),
                onMapCreated: _onMapCreated,
                onCameraChangeListener: (cameraChangedEventData) {
                  // Track bearing for compass visibility
                  final bearing = cameraChangedEventData.cameraState.bearing;
                  if (bearing != _mapBearing) {
                    setState(() {
                      _mapBearing = bearing;
                    });
                  }
                },
                cameraOptions: CameraOptions(
                  center: MapController.defaultCenter,
                  zoom: MapController.defaultZoom,
                ),
              ),

              // Map control buttons - right side, bound to bottom sheet position
              // Hide when sheet is maximized (> 90%)
              if (_currentSheetSize < 0.9)
                Positioned(
                  right: 16,
                  bottom: MediaQuery.of(context).size.height * _currentSheetSize + 16,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Compass button - only show when map is rotated (not aligned to north)
                      if (_mapBearing.abs() > 1.0) ...[
                        FloatingActionButton.small(
                          heroTag: 'compass_fab',
                          onPressed: _mapController.resetBearing,
                          backgroundColor: colorScheme.surface,
                          foregroundColor: colorScheme.primary,
                          elevation: 2,
                          child: Transform.rotate(
                            angle: -_mapBearing * (3.14159265359 / 180),
                            child: const Icon(Icons.navigation_rounded),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      // Location button
                      FloatingActionButton.small(
                        heroTag: 'location_fab',
                        onPressed: _mapController.goToUserLocation,
                        backgroundColor: colorScheme.surface,
                        foregroundColor: _mapController.locationPermissionGranted
                            ? colorScheme.primary
                            : colorScheme.outline,
                        elevation: 2,
                        child: Icon(
                          _mapController.locationPermissionGranted
                              ? Icons.my_location_rounded
                              : Icons.location_disabled_rounded,
                        ),
                      ),
                    ],
                  ),
                ),

              // Search overlay at top of screen
              if (_isSearchVisible)
                RoutesSearchBar(
                  routes: state.routes,
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  onSearchChanged: _onSearchChanged,
                  onClose: _toggleSearch,
                  onSuggestionSelected: (city) {
                    _onSearchChanged(city);
                    setState(() {
                      _isSearchVisible = false;
                      _searchFocusNode.unfocus();
                    });
                  },
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
                  return RoutesBottomSheet(
                    controller: _sheet,
                    scrollController: scrollController,
                    state: state,
                    onSearchPressed: _toggleSearch,
                    minSize: _min,
                    midSize: _mid,
                    maxSize: _max,
                    snapSizes: snapSizes,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
